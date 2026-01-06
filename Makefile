all_sync: all sync
all: fixes build gallery/index.html
./gallery/page.md: ./manage ./inputs/
	mkdir -p ./gallery
	echo '---\ntitle: pictures!\n---\n' >gallery/page.md
	./manage markdown | tee -a gallery/page.md
./gallery/index.html: ./gallery/page.md Makefile
	pandoc -s --template=template.html ./gallery/page.md | html-head | picofy --theme dark  | sponge ./gallery/index.html
build:
	./manage build
fixes:
	@# make sure permissions on images are readable by remote server
	fd -i jpg inputs -x chmod +r
sync:
	retry -- rsync -Pavhz --delete-after gallery/ vultr:static_files/gallery
clean:
	rm -rf gallery
