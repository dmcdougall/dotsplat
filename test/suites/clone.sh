#!/usr/bin/env bash -e

function oneTimeSetUp() {
	source $DOTSPLAT_FN_SRC
}

function tearDown() {
	find "$HOME" -mindepth 1 -not -path "${DOTSPLAT}*" -delete
}

function testCloning() {
	$DOTSPLAT_FN --batch clone $REPO_FIXTURES/rc-files > /dev/null
	assertSame "\`clone' did not exit with status 0" 0 $?
	rm -rf "$DOTSPLAT/repos/rc-files"
}

function testCloningSpacesInName() {
	$DOTSPLAT_FN --batch clone $REPO_FIXTURES/repo\ with\ spaces\ in\ name > /dev/null
	local repo_path="$DOTSPLAT/repos/repo with spaces in name"
	assertSame "\`clone' did not exit with status 0" 0 $?
	assertTrue "\`clone' did not clone to \`$repo_path'" "[ -d \"$repo_path\" ]"
	rm -rf "$DOTSPLAT/repos/repo with spaces in name"
}

function testSymlinkPrompt() {
	open_bracket="\\u005b"
	close_bracket="\\u005d"
	esc="\\u001b$open_bracket"
	if $EXPECT_INSTALLED; then
		cat <<EOF | expect -f - > /dev/null
			spawn $DOTSPLAT_BIN clone $REPO_FIXTURES/rc-files
			expect -ex "${esc}1;36m        clone${esc}0m $REPO_FIXTURES/rc-files\r${esc}1;32m        clone${esc}0m $REPO_FIXTURES/rc-files\r
${esc}1;37m      updates${esc}0m The castle rc-files has new files.\r
${esc}1;36m     symlink?${esc}0m ${open_bracket}yN${close_bracket} " {} default {exit 1}
			send "y\n"
			expect EOF
EOF
	else
		startSkipping
	fi
	assertEquals "Failed verifying the clone command output." 0 $?
	assertTrue "bashrc not symlinked after prompt" "[ -f $HOME/.bashrc ]"
	rm -f "$HOME/.bashrc"
	rm -rf "$DOTSPLAT/repos/rc-files"
}

function testDotInRepoName() {
	$DOTSPLAT_FN --batch clone $REPO_FIXTURES/135.abc > /dev/null
	assertSame "\`clone' did not exit with status 0" 0 $?
	assertTrue "The cloned repo was not named 135.abc" "[ -e \"$DOTSPLAT/repos/135.abc\" ]"
	rm -rf "$DOTSPLAT/repos/135.abc"

}

source $SHUNIT2
