
TEST_DIRS=basic lookup markup lists map sum unique

TEST_DIRS_TEST=$(TEST_DIRS:%=%__TEST__)
TEST_DIRS_CLEAN=$(TEST_DIRS:%=%__CLEAN__)
TEST_DIRS_INIT=$(TEST_DIRS:%=%__INIT__)

all: init tests

tests: $(TEST_DIRS_TEST)
	@echo All tests pass.

clean: $(TEST_DIRS_CLEAN)
init: $(TEST_DIRS_INIT) test-entities.xml

test-entities.xml:
	@echo '<?xml version="1.0" encoding="utf-8"?>' > $@
	@echo "<!ENTITY abs-test-path '$(shell pwd)'>" >> $@

$(TEST_DIRS_TEST):
	@make -C $(@:%__TEST__=%)

$(TEST_DIRS_CLEAN):
	@make -C $(@:%__CLEAN__=%) clean

$(TEST_DIRS_INIT):
	@cd $(@:%__INIT__=%) && [ -e Makefile ] || ln -s ../Make.tests Makefile

.PHONY: $(TEST_DIRS_TEST) $(TEST_DIRS_CLEAN) $(TEST_DIRS_INIT) all clean

