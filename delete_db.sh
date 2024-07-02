read -p "Are you sure you want to delete the database? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    rm -f opfsdp.sqlite
    rm -f ./data/adj/decomposition/*
    rm -f ./data/adj/instance/*
    rm -rf .logs/*
fi

