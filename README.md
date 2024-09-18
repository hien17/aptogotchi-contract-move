```shell
./sh_scripts/move_test.sh
bash: ./sh_scripts/move_test.sh: Permission denied
```
```shell
sudo ./sh_scripts/move_test.sh
sudo: ./sh_scripts/move_test.sh: command not found
```

```shell
ls -l sh_scripts/move_test.sh
-rw-r--r-- 1 hien hien 101 Sep 18 11:45 sh_scripts/move_test.sh
```
```shell
chmod +x sh_scripts/move_test.sh
```
```shell
ls -l sh_scripts/move_test.sh
-rwxr-xr-x 1 hien hien 101 Sep 18 11:45 sh_scripts/move_test.sh
```
https://stackoverflow.com/questions/12996397/command-not-found-when-using-sudo


## Use chmod to add executable permission 
```shell
chmod +x sh_scripts/script_setup.sh
```
Then run the script of setup
```shell
./sh_scripts/script_setup.sh
```
## Run unit tests
```shell
./sh_scripts/move_test.sh
```
## Publish Modules
```shell
./sh_scripts/move_publish.sh
```
## Run move scripts
### Create gotchi
```shell
./sh_scripts/move_run_script_create_gotchi.sh
```
### Feed gotchi.
```shell
./sh_scripts/move_run_script_feed_gotchi.sh
```

```shell
##### Running tests #####
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY AptosTokenObjects
INCLUDING DEPENDENCY MoveStdlib
BUILDING aptogotchi
Running Move unit tests
[ PASS    ] 0x100::main::test_create_aptogotchi
[ PASS    ] 0x100::main::test_create_aptogotchi_twice
[ PASS    ] 0x100::main::test_create_aptogotchi_without_creation
[ PASS    ] 0x100::main::test_feed_and_play
[ PASS    ] 0x100::main::test_set_name
[ PASS    ] 0x100::main::test_set_parts
Test result: OK. Total tests: 6; passed: 6; failed: 0
{
  "Result": "Success"
}


##### Publishing module #####
Compiling, may take a little while to download git dependencies...
UPDATING GIT DEPENDENCY https://github.com/aptos-labs/aptos-core.git
UPDATING GIT DEPENDENCY https://github.com/aptos-labs/aptos-core.git
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY AptosTokenObjects
INCLUDING DEPENDENCY MoveStdlib
BUILDING aptogotchi
package size 6923 bytes
Transaction submitted: https://explorer.aptoslabs.com/txn/0x0339d709b1ec54a276f7f066670882d087a4093ac649367e8647f659dfab41b0
{
  "Result": {
    "transaction_hash": "0x0339d709b1ec54a276f7f066670882d087a4093ac649367e8647f659dfab41b0",
    "gas_used": 5269,
    "gas_unit_price": 100,
    "sender": "56313a0ccd30f4dc579898ad6371606e72ded45a9d0539ad25cb795af465b373",
    "sequence_number": 19,
    "success": true,
    "timestamp_us": 1726644132239984,
    "version": 6002917255,
    "vm_status": "Executed successfully"
  }
}


##### Running move script to create gotchi #####
Compiling, may take a little while to download git dependencies...
UPDATING GIT DEPENDENCY https://github.com/aptos-labs/aptos-core.git
UPDATING GIT DEPENDENCY https://github.com/aptos-labs/aptos-core.git
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY AptosTokenObjects
INCLUDING DEPENDENCY MoveStdlib
BUILDING aptogotchi
{
  "Result": [
    "56313a0ccd30f4dc579898ad6371606e72ded45a9d0539ad25cb795af465b373::main"
  ]
}
Do you want to submit a transaction for a range of [113700 - 170500] Octas at a gas unit price of 100 Octas? [yes/no] >
yes
Transaction submitted: https://explorer.aptoslabs.com/txn/0x105314c5eac1d19af6718ea079ae50cf97bdd49dafb49480989f5efd4779581e
{
  "Result": {
    "transaction_hash": "0x105314c5eac1d19af6718ea079ae50cf97bdd49dafb49480989f5efd4779581e",
    "gas_used": 1137,
    "gas_unit_price": 100,
    "sender": "56313a0ccd30f4dc579898ad6371606e72ded45a9d0539ad25cb795af465b373",
    "sequence_number": 20,
    "success": true,
    "timestamp_us": 1726644164441732,
    "version": 6002919053,
    "vm_status": "Executed successfully"
  }
}


##### Running move script to feed gotchi #####
Compiling, may take a little while to download git dependencies...
UPDATING GIT DEPENDENCY https://github.com/aptos-labs/aptos-core.git
UPDATING GIT DEPENDENCY https://github.com/aptos-labs/aptos-core.git
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY AptosTokenObjects
INCLUDING DEPENDENCY MoveStdlib
BUILDING aptogotchi
{
  "Result": [
    "56313a0ccd30f4dc579898ad6371606e72ded45a9d0539ad25cb795af465b373::main"
  ]
}
Do you want to submit a transaction for a range of [1600 - 2400] Octas at a gas unit price of 100 Octas? [yes/no] >
yes
Transaction submitted: https://explorer.aptoslabs.com/txn/0xdf4bcab0c7da3162a0fe9478a2803795804d38f1bf6e3e076695e402a5e914dd
{
  "Result": {
    "transaction_hash": "0xdf4bcab0c7da3162a0fe9478a2803795804d38f1bf6e3e076695e402a5e914dd",
    "gas_used": 16,
    "gas_unit_price": 100,
    "sender": "56313a0ccd30f4dc579898ad6371606e72ded45a9d0539ad25cb795af465b373",
    "sequence_number": 21,
    "success": true,
    "timestamp_us": 1726644734743046,
    "version": 6002954057,
    "vm_status": "Executed successfully"
  }
}
```