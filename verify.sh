
RED='\033[1;31m'
GREEN='\033[1;32m'
NC='\033[0m' # No Color
rm -f ./data/verified.csv > /dev/null
rm -f ./data/failed.csv > /dev/null
rm -rf ./test > /dev/null
while IFS=, read crate_id name updated_at created_at downloads repository version; 
do 
    cargo-download -x "$name==$version" --output ./test 1> /dev/null
    if (cd test && cargo check --lib 1> /dev/null); then
        echo "${GREEN}PASSED${NC} $name\n" 
        echo "$crate_id,$name" >> ./data/verified.csv
    else
        echo "${RED}FAILED${NC} $name\n"
        echo "$crate_id,$name" >> ./data/failed.csv
    fi
    rm -rf ./test
done < top20.csv
echo "${GREEN}FINISHED!${NC} $name\n" 