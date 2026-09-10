#!/usr/bin/env python3
"""
parse_claude_session.py
Claude Code의 로컬 세션 로그(.jsonl)를 파싱하여 Antigravity(agy)가 인계받을 수 있는 마크다운 브리핑으로 출력합니다.
"""

import os
import sys
import json
import re
import argparse
from datetime import datetime
from pathlib import Path

CLAUDE_BASE_DIR = Path.home() / ".claude"
CLAUDE_PROJECTS_DIR = CLAUDE_BASE_DIR / "projects"


def encode_project_path(path: str) -> str:
    """Claude Code가 사용하는 프로젝트 디렉토리 인코딩 규칙 (비영숫자를 하이픈으로 치환)"""
    abs_path = os.path.abspath(path)
    return re.sub(r'[^a-zA-Z0-9]', '-', abs_path)


def find_project_dir(target_cwd: str) -> Path | None:
    """현재 target_cwd에 해당하는 Claude Code 프로젝트 디렉토리를 탐색"""
    if not CLAUDE_PROJECTS_DIR.is_dir():
        return None

    encoded_name = encode_project_path(target_cwd)
    candidate = CLAUDE_PROJECTS_DIR / encoded_name
    if candidate.is_dir():
        return candidate

    # Fallback: 디렉토리명 유사도 및 jsonl 파일 내부 cwd 검사
    abs_target = os.path.abspath(target_cwd)
    for pdir in CLAUDE_PROJECTS_DIR.iterdir():
        if not pdir.is_dir():
            continue
        # jsonl 파일 하나를 열어서 cwd 확인
        jsonl_files = list(pdir.glob("*.jsonl"))
        for jf in jsonl_files[:2]:
            try:
                with open(jf, "r", encoding="utf-8", errors="ignore") as f:
                    for _ in range(20):
                        line = f.readline()
                        if not line:
                            break
                        if '"cwd"' in line:
                            data = json.loads(line)
                            if data.get("cwd") == abs_target:
                                return pdir
            except Exception:
                continue

    return None


def get_sessions(project_dir: Path) -> list[dict]:
    """프로젝트 폴더 내 세션 jsonl 파일 목록을 최신 수정 시간 순으로 반환"""
    sessions = []
    for f in project_dir.glob("*.jsonl"):
        stat = f.stat()
        sessions.append({
            "id": f.stem,
            "path": f,
            "mtime": stat.st_mtime,
            "size": stat.st_size
        })
    sessions.sort(key=lambda s: s["mtime"], reverse=True)
    return sessions


def parse_session_file(session_path: Path, max_turns: int = 10, detail_tools: bool = False) -> dict:
    """세션 jsonl 파일에서 대화 내용 및 메타데이터 파싱"""
    meta = {
        "sessionId": session_path.stem,
        "cwd": "",
        "gitBranch": "",
        "version": "",
        "firstTimestamp": "",
        "lastTimestamp": "",
        "totalMessages": 0
    }

    turns = []
    current_turn = None

    with open(session_path, "r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                entry = json.loads(line)
            except Exception:
                continue

            entry_type = entry.get("type")

            # 메타데이터 추출
            if not meta["cwd"] and entry.get("cwd"):
                meta["cwd"] = entry.get("cwd")
            if not meta["gitBranch"] and entry.get("gitBranch"):
                meta["gitBranch"] = entry.get("gitBranch")
            if not meta["version"] and entry.get("version"):
                meta["version"] = entry.get("version")
            if entry.get("timestamp"):
                ts = entry["timestamp"]
                if not meta["firstTimestamp"]:
                    meta["firstTimestamp"] = ts
                meta["lastTimestamp"] = ts

            # 사용자 메시지
            if entry_type == "user":
                meta["totalMessages"] += 1
                msg = entry.get("message", {})
                content = msg.get("content", "")
                if isinstance(content, list):
                    text_parts = [c.get("text", "") for c in content if isinstance(c, dict) and c.get("type") == "text"]
                    content = "\n".join(text_parts)

                # 새로운 대화 턴 시작
                current_turn = {
                    "user_text": content.strip(),
                    "user_ts": entry.get("timestamp", ""),
                    "assistant_text": [],
                    "tools": [],
                    "model": ""
                }
                turns.append(current_turn)

            # 어시스턴트 메시지
            elif entry_type == "assistant":
                meta["totalMessages"] += 1
                msg = entry.get("message", {})
                if not current_turn:
                    current_turn = {
                        "user_text": "(No initial user prompt)",
                        "user_ts": "",
                        "assistant_text": [],
                        "tools": [],
                        "model": msg.get("model", "")
                    }
                    turns.append(current_turn)

                if msg.get("model") and not current_turn["model"]:
                    current_turn["model"] = msg.get("model")

                content_blocks = msg.get("content", [])
                if isinstance(content_blocks, str):
                    current_turn["assistant_text"].append(content_blocks)
                elif isinstance(content_blocks, list):
                    for b in content_blocks:
                        if not isinstance(b, dict):
                            continue
                        btype = b.get("type")
                        if btype == "text":
                            txt = b.get("text", "").strip()
                            if txt:
                                current_turn["assistant_text"].append(txt)
                        elif btype == "tool_use":
                            tool_name = b.get("name", "tool")
                            tool_input = b.get("input", {})
                            summary_arg = ""
                            if tool_name in ("Bash", "run_command"):
                                cmd = tool_input.get("command", "")
                                summary_arg = (cmd[:90] + "...") if len(cmd) > 90 else cmd
                            elif tool_name in ("Read", "Edit", "Write", "view_file", "write_to_file", "replace_file_content"):
                                summary_arg = tool_input.get("file_path", tool_input.get("TargetFile", tool_input.get("path", "")))
                            elif tool_name in ("Grep", "Glob", "grep_search", "find_by_name"):
                                summary_arg = tool_input.get("pattern", tool_input.get("Query", tool_input.get("path", "")))
                            elif tool_name == "Task":
                                summary_arg = tool_input.get("description", tool_input.get("subagent_type", ""))
                            else:
                                summary_arg = str(list(tool_input.keys()))

                            current_turn["tools"].append({
                                "name": tool_name,
                                "summary": summary_arg,
                                "input": tool_input if detail_tools else None
                            })

    # 최근 턴만 필터링
    trimmed_turns = turns[-max_turns:] if max_turns > 0 else turns

    return {
        "meta": meta,
        "turns": trimmed_turns,
        "total_turns": len(turns)
    }


def format_markdown_report(session_data: dict, session_idx: int = 1, total_sessions: int = 1) -> str:
    """파싱된 세션 데이터를 깔끔한 Markdown 보고서로 포맷팅"""
    meta = session_data["meta"]
    turns = session_data["turns"]
    total_turns = session_data["total_turns"]

    out = []
    header_prefix = f"### [Session {session_idx}/{total_sessions}]" if total_sessions > 1 else "##"
    out.append(f"{header_prefix} 🤖 Claude Code Session: `{meta['sessionId']}`\n")
    out.append(f"- **Project Path**: `{meta['cwd'] or 'Unknown'}`")
    out.append(f"- **Git Branch**: `{meta['gitBranch'] or 'N/A'}`")
    out.append(f"- **Session Duration**: `{meta['firstTimestamp']}` ~ `{meta['lastTimestamp']}`")
    out.append(f"- **Total Turns in Session**: {total_turns} (Displaying last {len(turns)} turns)\n")

    if not turns:
        out.append("> *No user/assistant interaction turns found in this session.*\n")
        return "\n".join(out)

    out.append("### 📝 Recent Conversation History\n")

    for i, turn in enumerate(turns, 1):
        ts_str = f" ({turn['user_ts']})" if turn['user_ts'] else ""
        out.append(f"#### 👤 Turn {i} - User{ts_str}")
        user_snippet = turn['user_text']
        if len(user_snippet) > 800:
            user_snippet = user_snippet[:800] + "\n... *(User prompt truncated)*"
        out.append(f"```text\n{user_snippet}\n```\n")

        model_info = f" ({turn['model']})" if turn['model'] else ""
        out.append(f"#### 🤖 Turn {i} - Claude{model_info}")

        if turn["assistant_text"]:
            combined_text = "\n\n".join(turn["assistant_text"])
            if len(combined_text) > 1200:
                combined_text = combined_text[:1200] + "\n... *(Assistant text truncated)*"
            out.append(f"{combined_text}\n")
        else:
            out.append("*(Tool execution only without direct text)*\n")

        if turn["tools"]:
            out.append("**🛠️ Executed Tools:**")
            for t in turn["tools"]:
                out.append(f"- `{t['name']}`: {t['summary']}")
            out.append("")

    # 마지막 턴 기반 핵심 요약/인계 포인트
    last_turn = turns[-1]
    out.append("### 🎯 Handoff Key Focus (마지막 작업 상태)")
    out.append(f"- **Last User Request**: {last_turn['user_text'][:150]}...")
    if last_turn['assistant_text']:
        out.append(f"- **Last Claude Response**: {last_turn['assistant_text'][-1][:200]}...")
    if last_turn['tools']:
        recent_tools = [f"`{t['name']}`" for t in last_turn['tools'][-3:]]
        out.append(f"- **Last Executed Actions**: {', '.join(recent_tools)}")
    out.append("\n---\n")

    return "\n".join(out)


def list_sessions_summary(project_dir: Path, target_cwd: str):
    """세션 목록을 터미널에 요약 출력"""
    sessions = get_sessions(project_dir)
    print(f"\n📂 Claude Code Sessions for `{target_cwd}`")
    print(f"Total Sessions: {len(sessions)}\n")
    print(f"{'No.':<4} {'Session ID':<38} {'Last Modified':<20} {'Size':<10}")
    print("-" * 75)

    for i, s in enumerate(sessions, 1):
        mtime_str = datetime.fromtimestamp(s["mtime"]).strftime("%Y-%m-%d %H:%M:%S")
        size_kb = f"{s['size'] / 1024:.1f} KB"
        print(f"{i:<4} {s['id']:<38} {mtime_str:<20} {size_kb:<10}")
    print()


def main():
    parser = argparse.ArgumentParser(description="Extract and summarize Claude Code session history for Antigravity handoff.")
    parser.add_argument("-C", "--cwd", default=os.getcwd(), help="Target project directory (default: current working directory)")
    parser.add_argument("-n", "--count", type=int, default=1, help="Number of recent sessions to retrieve (default: 1)")
    parser.add_argument("-s", "--session", default="", help="Specific session ID or prefix to inspect")
    parser.add_argument("-l", "--list", action="store_true", help="List all available sessions for this project")
    parser.add_argument("--max-turns", type=int, default=5, help="Number of recent conversation turns to extract per session (default: 5, 0 for all)")
    parser.add_argument("--detail", action="store_true", help="Include detailed tool inputs")
    parser.add_argument("--json", action="store_true", help="Output raw JSON instead of Markdown")

    args = parser.parse_args()

    project_dir = find_project_dir(args.cwd)
    if not project_dir:
        print(f"⚠️ Claude Code project directory not found for: {args.cwd}", file=sys.stderr)
        print(f"Checked in: {CLAUDE_PROJECTS_DIR}", file=sys.stderr)
        sys.exit(1)

    if args.list:
        list_sessions_summary(project_dir, args.cwd)
        return

    sessions = get_sessions(project_dir)
    if not sessions:
        print(f"⚠️ No session logs found in: {project_dir}", file=sys.stderr)
        sys.exit(1)

    selected_sessions = []
    if args.session:
        # 특정 세션 지정
        matched = [s for s in sessions if s["id"].startswith(args.session)]
        if not matched:
            print(f"⚠️ Session matching '{args.session}' not found.", file=sys.stderr)
            sys.exit(1)
        selected_sessions = matched[:args.count]
    else:
        # 최근 N개 세션 (기본 1개)
        selected_sessions = sessions[:args.count]

    results = []
    for s in selected_sessions:
        parsed = parse_session_file(s["path"], max_turns=args.max_turns, detail_tools=args.detail)
        results.append(parsed)

    if args.json:
        print(json.dumps(results, ensure_ascii=False, indent=2))
    else:
        print("# 📋 Claude Code -> Antigravity Handoff Briefing\n")
        print(f"> Project: `{os.path.abspath(args.cwd)}`\n")
        for i, parsed in enumerate(results, 1):
            report = format_markdown_report(parsed, session_idx=i, total_sessions=len(results))
            print(report)


if __name__ == "__main__":
    main()
