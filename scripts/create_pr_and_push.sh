#!/usr/bin/env bash
set -euo pipefail

# Skrip bantu: buat branch, commit perubahan yang sudah ada di workspace,
# push ke remote, dan buka Pull Request menggunakan gh (GitHub CLI).
# Jalankan dari root repo: bash scripts/create_pr_and_push.sh

BRANCH_NAME="add/pdf-server-ci-$(date +%Y%m%d%H%M%S)"
PR_TITLE="CI: Build & Push pdf-server Docker image"
PR_BODY="Menambahkan GitHub Actions workflow untuk build dan push Docker image 'pdf-server', plus README deploy (Bahasa Indonesia).\n\n- File: .github/workflows/docker-publish.yml\n- File: pdf-server/README.md\n- File: scripts/create_pr_and_push.sh\n\nSilakan tinjau dan merge." 

echo "Membuat branch: $BRANCH_NAME"
git checkout -b "$BRANCH_NAME"

echo "Menambahkan file yang berubah ke commit"
git add .github/workflows/docker-publish.yml pdf-server/README.md || true
git add -A

echo "Membuat commit"
git commit -m "$PR_TITLE" || { echo "Tidak ada perubahan untuk di-commit."; }

echo "Push branch ke origin"
git push -u origin "$BRANCH_NAME"

if command -v gh >/dev/null 2>&1; then
  echo "Membuka Pull Request lewat gh..."
  gh pr create --title "$PR_TITLE" --body "$PR_BODY" --base main --head "$BRANCH_NAME"
  echo "PR dibuat. Buka:"
  gh pr view --web
else
  echo "gh CLI tidak ditemukan. Silakan buat PR manual di GitHub atau install gh: https://cli.github.com/"
  echo "URL untuk buat PR manual: https://github.com/$(git config --get remote.origin.url | sed -E 's#(git@github.com:|https://github.com/)##; s/.git$//')/compare/main...$BRANCH_NAME?expand=1"
fi

echo "Selesai. Silakan tinjau PR dan merge ketika siap."
