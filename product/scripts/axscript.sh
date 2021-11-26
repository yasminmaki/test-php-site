#!/bin/bash
 
# Declare features
cleanup(){
# Delete the scan
Dummy=`curl -sS -k -X DELETE "$MyAXURL/scans/{$MyScanID}" -H "Settle for: utility/json" -H "X-Auth: $MyAPIKEY"`
# Delete the goal
Dummy=`curl -sS -k -X DELETE "$MyAXURL/targets/{$MyTargetID}" -H "Settle for: utility/json" -H "X-Auth: $MyAPIKEY"`
}

# Create our meant goal
MyTargetID=`curl -sS -k -X POST $MyAXURL/targets -H "Content material-Kind: utility/json" -H "X-Auth: $MyAPIKEY" --data "{"handle":"$MyTargetURL","description":"$MyTargetDESC","kind":"default","criticality":10}" | grep -Po '"target_id": *Ok"[^"]*"' | tr -d '"'`

# Set off a scan of the goal
MyScanID=`curl -i -sS -k -X POST $MyAXURL/scans -H "Content material-Kind: utility/json" -H "X-Auth: $MyAPIKEY" --data "{"profile_id":"$ScanProfileID","incremental":false,"schedule":{"disable":false,"start_date":null,"time_sensitive":false},"user_authorized_to_scan":"sure","target_id":"$MyTargetID"}" | grep "Location: " | sed "s/Location: /api/v1/scans///" | sed "s/r//g" | sed -z "s/n//g"`

whereas true; do
 MyScanStatus=`curl -sS -k -X GET "$MyAXURL/scans/{$MyScanID}" -H "Settle for: utility/json" -H "X-Auth: $MyAPIKEY"`
 if [[ "$MyScanStatus" == *""status": "processing""* ]]; then
   echo "Scan Standing: Processing - ready 30 seconds"
 elif [[ "$MyScanStatus" == *""status": "scheduled""* ]]; then
   echo "Scan Standing: Scheduled - ready 30 seconds"
 elif [[ "$MyScanStatus" == *""status": "completed""* ]]; then
   echo "Scan Standing: Accomplished"
   # Get away of loop
   break
 else
   echo "Invalid Scan Standing: Aborting"
   # Clear Up and Exit script
   cleanup
   exit 1
 fi
 sleep 30
carried out

# Acquire the scan session ID
MyScanSessionID=`echo "$MyScanStatus" | grep -Po '"scan_session_id": *Ok"[^"]*"' | tr -d '"'`

# Acquire the scan consequence ID
MyScanResultID=`curl -sS -k -X GET "$MyAXURL/scans/{$MyScanID}/outcomes" -H "Settle for: utility/json" -H "X-Auth: $MyAPIKEY" | grep -Po '"result_id": *Ok"[^"]*"' | tr -d '"'`

# Acquire scan vulnerabilities
MyScanVulnerabilities=`curl -sS -k -X GET "$MyAXURL/scans/{$MyScanID}/outcomes/{$MyScanResultID}/vulnerabilities" -H "Settle for: utility/json" -H "X-Auth: $MyAPIKEY"`

# Rely vulnerabilities
MyVulnerabilityCount=$(echo $MyScanVulnerabilities | jq '.vulnerabilities | size')

# Exit with error if we discover vulnerabilities; exit WITHOUT error if vulnerabilities depend is 0
if [ $MyVulnerabilityCount -gt 0 ] ; then exit 1 ; else exit 0 ; fi
