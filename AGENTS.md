# AGENTS.md — Project Rules

## 保持脚本同步

`fix_mumu.ps1`、`fix_mumu.sh`、`fix_mumu.bat` 三份脚本必须保持逻辑一致。更改任一脚本时，必须同步修改其余脚本的对应逻辑。

## 保持 README 同步

如果有多个语言版本的 README（如 `README.md`、`README.zh.md` 等），更改内容时必须同步所有版本。

## 不覆盖用户配置

不改动 `.gitignore`、`AGENTS.md` 自身及用户明确要求保持的文件。
