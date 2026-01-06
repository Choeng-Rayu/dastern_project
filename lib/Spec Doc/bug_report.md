# LOCAL STORAGE
* when user create the new account and login into that new account it still load the old data. 
example i already have the old account name rayu and then i logout and i create another new account name rayu_new but it still load the data from the account rayu. 
so to fix it  when it load data in the new account must check json is the username and account is match with the old data json file (in the json format must stored password and username) if it matched old that data if it not match create the new local storage (not overwrite).
