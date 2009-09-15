
TEST_DIRS=basic lookup markup

TEST_DIRS_TEST=$(TEST_DIRS:%=%__TEST__)
TEST_DIRS_CLEAN=$(TEST_DIRS:%=%__CLEAN__)

all: $(TEST_DIRS_TEST)
clean: $(TEST_DIRS_CLEAN)

$(TEST_DIRS_TEST):
	make -C $(@:%__TEST__=%)

$(TEST_DIRS_CLEAN):
	make -C $(@:%__CLEAN__=%) clean

.PHONY: $(TEST_DIRS_TEST) $(TEST_DIRS_CLEAN) all clean

