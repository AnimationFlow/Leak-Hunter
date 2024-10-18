# Leak-Hunter

A Bash script to hunt down memory-leaking apps like VSC-Remote's node process when memory taken > threshold.

Interactive menu to add & remove cron job (runs every minute).

I set the process threshold at 32 %, about 2GB on a 6GB RAM system.


# Logs :

      tail /var/log/leak-hunter.log
      --- Sat Oct 19 00:43:01 CEST 2024 - No ps > 32% memory usage
      --- Sat Oct 19 00:43:43 CEST 2024 - Cron job removed
      --- Sat Oct 19 00:43:43 CEST 2024 - Removing script from /usr/local/bin/leak-hunter.sh
      --- Sat Oct 19 00:44:40 CEST 2024 - Copying script to /usr/local/bin/leak-hunter.sh
      --- Sat Oct 19 00:44:40 CEST 2024 - Cron job added: * * * * * /usr/local/bin/leak-hunter.sh
      --- Sat Oct 19 00:44:43 CEST 2024 - No ps > 32% memory usage
      --- Sat Oct 19 00:45:01 CEST 2024 - No ps > 32% memory usage
      --- Sat Oct 19 00:46:02 CEST 2024 - No ps > 32% memory usage
      --- Sat Oct 19 00:46:26 CEST 2024 - Asking process 521334 to stop nicely..
      --- Sat Oct 19 00:46:31 CEST 2024 - Process 521334 terminated gracefully


# Hunt on run (just enter or wait for timeout):

      === Leak Hunter started @ Sat Oct 19 00:46:21 CEST 2024 ===

      --- Cron jobs for leak-hunter.sh :

      1  * * * * * /usr/local/bin/leak-hunter.sh

            a : Add a cron job
            r : Remove a cron job

      default : Hunt Leaks

      timeout : 21 s

      ---> 

      --- Hunting leaks..

      PID   %CPU   %MEM   CMD
      ----------------------------
      521334 13.7 25.9 /root/.vscode-server/cli/servers/Stable-384ff7382de624fb94dbaf6da11977bba1ecd427/server/node --dns-result-order=ipv4first /root/.vscode-server/cli/servers/Stable-384ff7382de624fb94dbaf6da11977bba1ecd427/server/out/bootstrap-fork --type=extensionHost --transformURIs --useHostProxy=false

      --- Leaks detected :
      1. PID : 521334
      --- Asking process 521334 to stop nicely..
      --- Sat Oct 19 00:46:31 CEST 2024 - Process 521334 terminated gracefully

      === Leak Hunter go home @ Sat Oct 19 00:46:31 CEST 2024 ===


# Add a cron job :

      === Leak Hunter started @ Sat Oct 19 00:42:52 CEST 2024 ===

      --- Cron jobs for leak-hunter.sh :

            a : Add a cron job
            r : Remove a cron job

      default : Hunt Leaks

      timeout : 21 s

      ---> a

      --- Sat Oct 19 00:42:53 CEST 2024 - Copying script to /usr/local/bin/leak-hunter.sh
      --- Sat Oct 19 00:42:54 CEST 2024 - Cron job added: * * * * * /usr/local/bin/leak-hunter.sh

      === Leak Hunter go home @ Sat Oct 19 00:42:54 CEST 2024 ===


# Remove a cron job :

      === Leak Hunter started @ Sat Oct 19 00:43:41 CEST 2024 ===

      --- Cron jobs for leak-hunter.sh :

      1  * * * * * /usr/local/bin/leak-hunter.sh

            a : Add a cron job
            r : Remove a cron job

      default : Hunt Leaks

      timeout : 21 s

      ---> r

      --- Sat Oct 19 00:43:43 CEST 2024 - Cron job removed
      --- Sat Oct 19 00:43:43 CEST 2024 - Removing script from /usr/local/bin/leak-hunter.sh

      === Leak Hunter go home @ Sat Oct 19 00:43:44 CEST 2024 ===
