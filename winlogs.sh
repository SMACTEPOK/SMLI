#!/bin/bash -
#
# winlogs.sh
#
# Описание:
# Собираем копии файлов журнала Windows #
# Использование:
# winlogs.sh [-z]
# -z Заархивировать вывод
#
TGZ=0
if (( $# > 0 ))
then
    if [[ ${1:0:2} == '-z' ]]
    then
        TGZ=1
        shift
    fi
fi
SYSNAM=$(hostname)
LOGDIR=${1:-/tmp/${SYSNAM}_logs}
mkdir -p $LOGDIR
cd ${LOGDIR} || exit -2
TOTAL_JOURNALS=$(wevtutil el | wc -l)
CURRENT_JOURNAL=0
wevtutil el | while read ALOG
do
    ALOG="${ALOG%$'\r'}"
    echo -ne "\r${ALOG}:"
    SAFNAM="${ALOG// /_}"
    SAFNAM="${SAFNAM//\//-}"
    wevtutil epl "$ALOG" "${SYSNAM}_${SAFNAM}.evtx" > /dev/null 2>&1
    CURRENT_JOURNAL=$((CURRENT_JOURNAL + 1))
    echo -ne "\r" -n "+"
done
echo -ne "\n"
if (( TGZ == 1 ))
then
    tar -czvf ${SYSNAM}_logs.tgz *.evtx
fi
