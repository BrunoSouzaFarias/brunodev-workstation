.PHONY: help lint format test test-e2e

help:
	@echo "Comandos disponíveis:"
	@echo "  make lint      - Verifica regras de código (ShellCheck, MarkdownLint)"
	@echo "  make format    - Formata os scripts (.sh, .bats) com shfmt"
	@echo "  make test      - Roda testes unitários localmente"
	@echo "  make test-e2e  - Roda instalação completa num container isolado (Docker)"

lint:
	./scripts/lint.sh

format:
	./scripts/format.sh

test:
	./tests/run-tests.sh

test-e2e:
	./tests/run-tests.sh --integracao