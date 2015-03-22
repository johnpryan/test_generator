# test generator example

```
generate_tests --no-react -d test/
run_tests test/generated_runner_test.dart
```

if any tests fail, `run_tests` will fail with an exit status of `1`:

```
echo $?
1
```

