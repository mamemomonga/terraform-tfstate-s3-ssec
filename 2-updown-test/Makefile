include ../etc/ssec.mk

.PHONY: all clean upload download

all: upload download
	cat var/hello.txt

upload: var/hello.txt
	aws s3api put-object \
	    --bucket $(S3_BUCKET) \
	    --sse-customer-algorithm AES256 \
	    --sse-customer-key "$(S3_SSEC_KEY)" \
	    --key hello.txt \
	    --body var/hello.txt

download:
	aws s3api get-object\
	    --bucket $(S3_BUCKET) \
	    --sse-customer-algorithm AES256 \
	    --sse-customer-key "$(S3_SSEC_KEY)" \
	    --key hello.txt \
	    var/download.txt

var:
	mkdir -p var

var/hello.txt: var
	date +'%Y/%m/%d %H:%M:%S'  > var/hello.txt
	echo "Hello World!" >> var/hello.txt

clean:
	rm -rf var
	aws s3api delete-object \
		--bucket $(S3_BUCKET) \
		--key hello.txt

