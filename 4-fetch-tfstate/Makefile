include ../etc/ssec.mk

.PHONY: all clean

download: var
	aws s3api get-object\
	    --bucket $(S3_BUCKET) \
	    --sse-customer-algorithm AES256 \
	    --sse-customer-key "$(S3_SSEC_KEY)" \
	    --key $(S3_TFSTATE_KEY) \
	    var/terraform.tfstate

var:
	mkdir -p var

purge:
	aws s3api delete-object \
		--bucket $(S3_BUCKET) \
		--key $(S3_TFSTATE_KEY)

clean:
	rm -rf var
