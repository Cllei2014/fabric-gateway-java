DOCKER_NS ?= hyperledger
SDKINTEGRATION = src/test/fixture/sdkintegration
MVN_ARGS = -Dmaven.test.failure.ignore=false

IMAGES = peer orderer ca tools

%: export IMAGE_PEER=$(DOCKER_NS)/fabric-peer-gm:latest
%: export IMAGE_ORDERER=$(DOCKER_NS)/fabric-orderer-gm:latest
%: export IMAGE_CA=$(DOCKER_NS)/fabric-ca-gm:latest
%: export IMAGE_TOOLS=$(DOCKER_NS)/fabric-tools-gm:latest

image-%:
	@docker inspect --type=image $$IMAGE_$(shell echo $* | tr a-z A-Z ) > /dev/null 2>&1  \
		|| docker pull $$IMAGE_$(shell echo $* | tr a-z A-Z ) \
		&& echo "$* image exsist."

images: $(patsubst %, image-%, $(IMAGES))

package:
	mvn $(MVN_ARGS) package -Dmaven.test.skip

tests: int-test

unit-test:
	mvn $(MVN_ARGS) clean test

# int-test will both run unit-test and int-test
int-test: clean
	mvn $(MVN_ARGS )clean integration-test
	make fabric-down

clean:
	docker run --rm -v "$$PWD/src/test/fixtures/crypto-material:/mnt" -w /mnt busybox rm -rf ordererOrganizations peerOrganizations

fabric-%: images
	cd src/test/fixtures/docker-compose && docker-compose -f docker-compose-tls.yaml -p node $*
