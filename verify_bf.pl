#!/usr/bin/perl -w
use strict;

use LWP::UserAgent;
use URI::URL;

my $ua = LWP::UserAgent->new();

TOP: while (my $line = <STDIN>) {
    print "\n\n";
    my $uri = {URI::URL->new($line)->query_form}->{"q"};

    if ($uri =~ /logkeeper\.mongodb\.org/) {
        my $task_uri = $uri;
        my $all_uri = $uri;
        
        $task_uri =~ s/$/?raw=1/;
        $all_uri =~ s/\/test\/[^\/]+\/$/\/all?raw=1/;

        my @content = map {
            my $uri = $_;
            my $res = $ua->get($uri);

            if (! $res->is_success) {
                die "Failed to get logs for ", $uri;
            }

            $res->decoded_content();
        } ($task_uri, $all_uri);

        foreach my $content (@content) {
            if ($content =~ /error_propagation\].+?assert: \["\$add only supports numeric or date types/) {
                print "https://jira.mongodb.org/browse/BF-2025\n";
                next TOP;
            }

            if ($content =~ /replsets_priority1\].+?Error: assert.soon failed, msg:awaiting replication/) {
                print "https://jira.mongodb.org/browse/BF-1927\n";
                next TOP;
            }

            if ($content =~ /server_status_metrics\].+?Error: assert failed : no \(oplog\) readers created/) {
                print "https://jira.mongodb.org/browse/BF-1969\n";
                next TOP;
            }

            if ($content =~ /js_protection\].+?assert failed$/m) {
                print "https://jira.mongodb.org/browse/BF-1868\n";
                next TOP;
            }

            if ($content =~ /^\[ValidateCollections:.+?index_multi failed to validate/) {
                print "https://jira.mongodb.org/browse/BF-1925\n";
                next TOP;
            }

            if ($content =~ /backup_restore\].+?Invariant failure.+?WT_ERROR/) {
                print "https://jira.mongodb.org/browse/BF-1445\n";
                next TOP;
            }

            if ($content =~ /js_test:tags\].+?"errmsg" : "waiting for replication timed out"/) {
                print "https://jira.mongodb.org/browse/BF-1976\n";
                next TOP;
            }

            if ($content =~ /killop\].+?assert\.soon failed, msg:/) {
                print "https://jira.mongodb.org/browse/BF-1944\n";
                next TOP;
            }

            if ($content =~ /exit_logging\].+?assert:$/m) {
                print "https://jira.mongodb.org/browse/BF-2069\n";
                next TOP;
            }

            if ($content =~ /job0\].+?WorkingSetCommon/) {
                print "https://jira.mongodb.org/browse/BF-2066\n";
                next TOP;
            }

            if ($content =~ /upsert_fields\].+?findOne query returned no results/) {
                print "https://jira.mongodb.org/browse/BF-1870\n";
                next TOP;
            }

            if ($content =~ /network_interface_asio_test\].+?getNumCanceledOps\(\) == canceled/) {
                print "https://jira.mongodb.org/browse/BF-2060\n";
                next TOP;
            }

            if ($content =~ /reconfig_without_increased_queues\].+?with _id 2 is not electable under the new configuration/) {
                print "https://jira.mongodb.org/browse/BF-1522\n";
                next TOP;
            }

            if ($content =~ /upsert_fields\].+?TypeError: coll\.findOne\(\.\.\.\) is null/) {
                print "https://jira.mongodb.org/browse/BF-1870\n";
                next TOP;
            }

            if ($content =~ /server6239\].+?TypeError: res\.toArray/) {
                print "https://jira.mongodb.org/browse/BF-2055\n";
                next TOP;
            }

            if ($content =~ /rollback\].+?assert\.soon failed/ &&
                $content =~ /rollback\.js:131/) {
                print "https://jira.mongodb.org/browse/BF-2023\n";
                next TOP;
            }

            if ($content =~ /scoped_db_conn_test\].+?Fatal Assertion 16727$/m) {
                print "https://jira.mongodb.org/browse/BF-2068\n";
                next TOP;
            }

            if ($content =~ /mr_during_migrate\].+?"errmsg" : "could not run map command on all shards for ns/) {
                print "https://jira.mongodb.org/browse/BF-2051\n";
                next TOP;
            }

            if ($content =~ /Invariant failure: ret resulted in status UnknownError: -31803: WT_NOTFOUND: item not found at src\/mongo\/db\/storage\/wiredtiger\/wiredtiger_record_store\.cpp 988/) {
                print "https://jira.mongodb.org/browse/BF-2038\n";
                next TOP;
            }

            if ($content =~ /pure virtual method called/) {
                print "https://jira.mongodb.org/browse/BF-1819\n";
                next TOP;
            }

            if ($content =~ /Too many open files in system/) {
                print "OS X     https://jira.mongodb.org/browse/BF-2043\n";
            }

            if ($content =~ /Invariant failure nss\.isValid\(\)/) {
                print "https://jira.mongodb.org/browse/BF-2021\n";
                next TOP;
            }

            if ($content =~ /CrashAtUnhandlableOOM/) {
                print "https://jira.mongodb.org/browse/BF-2048\n";
                next TOP;
            }

            if ($content =~ /Invariant failure now\(\) >= when src\/mongo\/executor\/thread_pool_task_executor\.cpp 260/) {
                print "https://jira.mongodb.org/browse/BF-2037\n";
                next TOP;
            }
        }

        print "Unknown failure...\n";

        open FILE, ">task.log" or die "terribly";
        print FILE $content[0];
        close FILE or die "terribly";

        open FILE, ">all.log" or die "terribly";
        print FILE $content[1];
        close FILE or die "terribly";
    } elsif ($uri =~ /evergreen\.mongodb\.com/) {
        $uri =~ s/$/\/0?type=ALL&text=true/;
        $uri =~ s/^https:\/\/evergreen\.mongodb\.com\/task/https:\/\/evergreen.mongodb.com\/task_log_raw/;
        print "$uri\n";

        my $res = $ua->get($uri);

        if (! $res->is_success) {
            die "Failed to get logs for ", $uri;
        }

        my $content = $res->decoded_content();

        if ($content =~ /cannot allocate memory/) {
            print "https://jira.mongodb.org/browse/BF-2048\n";
            next TOP;
        }

        if ($content =~ /Calling the hang analyzer/) {
            print "jstestfuzz: https://jira.mongodb.org/browse/BF-2049\n";
            if ($content =~ /Task timed out/) {
                print "sharding: https://jira.mongodb.org/browse/BF-1460\n";
            }
        }

        my @mongo_procs = grep {
            /admin\s+\d+\s+[0-9.]+\s+([0-9.]+).+?mongo/ ? $1 > 80 ? 1 : 0 : 0;
        } split /\n/, $content;

        if (@mongo_procs) {
            print "https://jira.mongodb.org/browse/BF-2048\n";
            next TOP;
        }

        print "Unknown failure...\n";

        open FILE, ">system_all.log" or die "terribly";
        print FILE $content;
        close FILE or die "terribly";
    }
}
