
RED='\033[1;31m'
GREEN='\033[1;32m'
NC='\033[0m' # No Color
cargo build 1> /dev/null
rm -f ./data/verified.csv > /dev/null
rm -rf ./test > /dev/null
while IFS=, read crate_id name updated_at created_at downloads repository version; 
do 
    if (cargo-download -x "$name==$version" --output ./test 1> /dev/null); then 
        if (./target/debug/cargo-ffi ./test); then 
            if (cd test && cargo check --lib 1> /dev/null); then
                echo "${GREEN}PASSED${NC} $name\n" 
                echo "$crate_id,$name,passed" >> ./data/verified.csv
            else
                echo "${RED}CHECK FAILED${NC} $name\n"
                echo "$crate_id,$name,check-failed" >> ./data/verified.csv
            fi
        else
            echo "${RED}NO ABI${NC} $name\n"
            echo "$crate_id,$name,noabi" >> ./data/verified.csv
        fi
    else
        echo "${RED}DOWNLOAD FAILED${NC} $name\n"
        echo "$crate_id,$name,download-failed" >> ./data/verified.csv
    fi
    rm -rf ./test
done < ./data/crates.csv
echo "${GREEN}FINISHED!${NC} $name\n" 