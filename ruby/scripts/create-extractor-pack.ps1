cd extractor
cargo build --release
cargo run --release --bin generator -- --dbscheme ../ql/lib/ruby.dbscheme --library ../ql/lib/codeql/ruby/ast/internal/TreeSitter.qll
cd ..

codeql query format -i ql\lib\codeql/ruby\ast\internal\TreeSitter.qll

rm -Recurse -Force extractor-pack
mkdir extractor-pack | Out-Null
cp codeql-extractor.yml, ql\lib\ruby.dbscheme, ql\lib\ruby.dbscheme.stats extractor-pack
cp -Recurse tools extractor-pack
cp -Recurse downgrades extractor-pack
mkdir extractor-pack\tools\win64 | Out-Null
cp extractor\target\release\ruby-extractor.exe extractor-pack\tools\win64\extractor.exe
cp extractor\target\release\ruby-autobuilder.exe extractor-pack\tools\win64\autobuilder.exe
