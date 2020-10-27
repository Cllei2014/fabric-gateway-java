DOCKER_NS ?= hyperledger
SDKINTEGRATION = src/test/fixture/sdkintegration
MVN_ARGS = -Dmaven.test.failure.ignore=false

IMAGES = peer orderer ca tools

image.peer     = $(DOCKER_NS)/fabric-peer-gm:latest
image.orderer  = $(DOCKER_NS)/fabric-orderer-gm:latest
image.ca       = $(DOCKER_NS)/fabric-ca-gm:latest
image.tools    = $(DOCKER_NS)/fabric-tools-gm:latest

%: export IMAGE_PEER=$(image.peer)
%: export IMAGE_ORDERER=$(image.orderer)
%: export IMAGE_CA=$(image.ca)
%: export IMAGE_TOOLS=$(image.tools)

image-%: 
	@docker inspect --type=image $(image.$*) > /dev/null 2>&1  \
		|| docker pull $(image.$*) \
		&& echo "$* image use $(image.$*)"

images: $(patsubst %, image-%, $(IMAGES))

package:
	mvn $(MVN_ARGS) package -Dmaven.test.skip

tests: int-test

unit-test:
	mvn $(MVN_ARGS) clean test

# int-test will both run unit-test and int-test
int-test: clean images
	mvn $(MVN_ARGS) clean integration-test
	make fabric-down

clean:
	@echo "Clean crypoto-material"
	@docker run --rm -v "$$PWD/src/test/fixtures/crypto-material:/mnt" -w /mnt busybox rm -rf ordererOrganizations peerOrganizations

fabric-%: images
	cd src/test/fixtures/docker-compose && docker-compose -f docker-compose-tls.yaml -p node $*
