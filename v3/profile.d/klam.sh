KLAM_USER=$(who -m | awk '{print $1}')
PROMPT_COMMAND='RETRN_VAL=$?;logger -p local6.debug "$KLAM_USER [$$]: $(history 1 | sed "s/^[ ]*[0-9]\+[ ]*//") [$RETRN_VAL]"'
