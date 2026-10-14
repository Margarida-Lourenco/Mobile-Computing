Current app repaired directly in C:/Users/wilma/Documents/Flutter/project/Mobile-Computing/my_app.

Restored 37 missing source/test files from the complete Spark archive, preserving existing files. The previous folder contained only the patch files.

Account creation now creates its private profile independently of member statistics. A counter permission/network failure cannot roll back a valid new account. Statistics synchronize separately after sign-in. Real profile setup failures now display their Firebase error code. Added two signup regression tests for counter denial and private-profile failure rollback.

Final Dart analyzer check: exit 0, no diagnostics, across lib and test. Widget tests were attempted but the environment blocked the test runner's local socket connection, so no test-suite pass is claimed. Restart the app fully, then try registration again. Run flutter test on your computer.

This archive contains the complete source app, not a partial patch. Firebase rules and the free Spark setup have not been changed. No live Firebase deployment, billing changes or account creation was performed.
