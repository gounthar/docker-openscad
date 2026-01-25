#!/bin/bash -e

clean () {
	rm -f ???_build-*.log
}

build () {
	DIR="$1"
	TAG="$2"
	NAME="${TAG#*/}"
	shift
	shift

	COUNT=$(( $COUNT + 1 ))
	LOG=$(printf "%03d_build-%s.log" "$COUNT" "$NAME")

	CPU=$(( ( $(nproc) + 1 ) / 2 ))
	MEM=$(cat /proc/meminfo | grep MemTotal: | awk '{ print 1 + int($2 / 1024 / 1024 / 8) }')
	JOBS=$(( $CPU < $MEM ? $CPU : $MEM ))

	echo "*" | tee "$LOG"
	echo "* $(date): building $NAME (using JOBS=$JOBS)" | tee -a "$LOG"
	echo "* $(date): log in $LOG" | tee -a "$LOG"
	echo "*" | tee -a "$LOG"
	time DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain docker buildx build \
		"$DIR" \
		"$@" \
		--load \
		-t "$TAG":latest \
		--progress=plain \
		--build-arg="JOBS=$JOBS" \
		-f "$DIR"/"$NAME"/Dockerfile \
		2>&1 | tee -a "$LOG"
	echo "*" | tee -a "$LOG"
	echo "* $(date): finished $NAME" | tee -a "$LOG"
	echo "*" | tee -a "$LOG"
}

list () {
	REF="$1"

	date
	docker image list -f "reference=${REF}"
}
