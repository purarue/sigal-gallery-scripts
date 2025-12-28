all_sync: all sync
all: fixes build index.html
sync_targets.txt: ./inputs ./index.html
	./manage list | xargs echo inputs index.html | tr ' ' '\n' > ./sync_targets.txt
page.md: ./manage ./inputs
	echo '---\ntitle: pictures!\n---\n' >page.md
	./manage markdown | tee -a page.md
index.html: ./page.md Makefile
	pandoc -s --template=template.html page.md | html-head | picofy --theme dark  | sponge index.html
build:
	./manage build
check-no-uppercase-jpg:
	@# make sure jpg are lowercase, uppercase doesn't serve mimetype properly
	@found=$$(find inputs -name '*.JPG'); \
	if [ -n "$$found" ]; then \
		echo "Error: Found uppercase JPG file(s):"; \
		echo "$$found"; \
		exit 1; \
	fi
fixes: check-no-uppercase-jpg
	@# make sure permissions on images are readable by remote server
	fd jpg inputs -x chmod +r
sync: sync_targets.txt
	retry -- rsync -Pavh --links --relative --delete-before `cat sync_targets.txt` vultr:static_files/gallery
clean:
	./manage clean
	rm -f index.html
