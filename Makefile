.PHONY: help pub get analyze test run web android ios clean commit push

# Flutter 项目 Makefile
FLUTTER := /home/believening/flutter/bin/flutter

help:
	@echo "FrameGuide Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  pub get    - 获取依赖"
	@echo "  analyze   - 代码分析"
	@echo "  test      - 运行测试"
	@echo "  run       - 运行应用"
	@echo "  web       - 运行 Web 版本"
	@echo "  android   - 运行 Android 版本"
	@echo "  ios       - 运行 iOS 版本"
	@echo "  clean     - 清理构建"
	@echo "  commit    - 提交更改"
	@echo "  push      - 推送到远程"

pub get:
	$(FLUTTER) pub get

analyze:
	$(FLUTTER) analyze

test:
	$(FLUTTER) test

run:
	$(FLUTTER) run

web:
	$(FLUTTER) run -d chrome

android:
	$(FLUTTER) run -d android

ios:
	$(FLUTTER) run -d ios

clean:
	$(FLUTTER) clean

commit:
	@git add -A
	@read -p "Commit message: " msg; \
	git commit -m "$$msg"

push:
	@export GITHUB_TOKEN=$$(gh auth token 2>/dev/null) && \
	git remote set-url origin "https://x-access-token:$${GITHUB_TOKEN}@github.com/believening/frameguide.git" && \
	git push
