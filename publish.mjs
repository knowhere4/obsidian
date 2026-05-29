#!/usr/bin/env node
import { execSync } from "child_process"
import { cpSync, existsSync, mkdirSync, rmSync } from "fs"
import { join, dirname } from "path"
import { fileURLToPath } from "url"

const QUARTZ_DIR = dirname(fileURLToPath(import.meta.url))
const CONTENT_DIR = join(QUARTZ_DIR, "content")
const OBSIDIAN_VAULT = process.argv[2]

if (!OBSIDIAN_VAULT) {
  console.error("사용법: node publish.mjs <obsidian-vault-path>")
  process.exit(1)
}

// Obsidian → content 동기화
console.log("Obsidian → content 동기화 중...")
if (existsSync(CONTENT_DIR)) {
  rmSync(CONTENT_DIR, { recursive: true })
}
mkdirSync(CONTENT_DIR)
cpSync(OBSIDIAN_VAULT, CONTENT_DIR, {
  recursive: true,
  filter: (src) => {
    const name = src.split(/[/\\]/).pop()
    return !name.startsWith(".obsidian") &&
           !name.startsWith(".trash") &&
           !name.endsWith(".canvas")
  },
})
console.log("동기화 완료")

// GitHub push
console.log("GitHub에 push 중...")
const message = process.argv[3] || `Quartz sync: ${new Date().toLocaleString("ko-KR")}`
execSync(`npx quartz sync --message "${message}"`, {
  cwd: QUARTZ_DIR,
  stdio: "inherit",
})
