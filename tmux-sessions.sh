SESSION_COUNT=$(tmux ls 2>/dev/null | wc -l)
if [[ "$SESSION_COUNT" -gt 0 ]]; then
	echo "Active tmux sessions (attach with 'tmux attach -t <id>'):"
	tmux ls 2>/dev/null
fi
