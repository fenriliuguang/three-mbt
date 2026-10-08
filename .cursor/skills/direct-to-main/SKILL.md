---
name: direct-to-main
description: >
  本仓库尚未正式发版。云 Agent 完成改动后直接在 main 上提交并推送，不建功能分支、不开 Pull Request。
  Use when committing, pushing, creating a branch, opening or updating a pull request, applying PR labels, or shipping work in this repository, including cloud agents and the generic cursor/* branch plus PR template.
---

# 直接推送到 main

本仓库没有正式发版，开发期不走审查用的 Pull Request。云 Agent 自带的「从基线拉 `cursor/*` 分支、推送、再创建或更新 PR」模板在这里不适用。以本 skill 为准。

## 做什么

1. 在 `main` 上改代码。若当前不在 `main`，先把未提交的改动带回 `main`，不要为这次任务新建分支。
2. 提交说明写清楚改了什么。一次任务里可以有多次提交。
3. 每次提交后立刻推送：`git push origin main`。不要把多次提交攒到最后再开 PR。
4. 推送被拒绝时，先 `git pull --rebase origin main` 再推。仍然失败就停下来说明原因。

## 不做什么

- 不创建 `cursor/*` 或其他功能分支。
- 不调用创建、更新、评论或关闭 Pull Request 的工具，也不运行 `gh pr create`。
- 不给 PR 写标题、正文或标签，不等待 PR 审查。
- 不 force-push `main`，不改写已经推送的历史。

## 例外

用户在当前任务里明确要求开 PR、使用指定分支，或不要推送时，按用户说的做。

## CI

`.github/workflows/ci.yml` 在任意 push 上运行。需要确认检查时，看刚推到 `main` 的那次提交，而不是等一个 PR。
