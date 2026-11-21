#!/usr/bin/env tclsh
# Lab 2 - Phan 5: tong hop cac log mo phong trong logs/.
proc doc_log {f} {
    set commit "?"
    set ket_qua "?"
    set sai "-"
    set handle [open $f r]
    while {[gets $handle line] >= 0} {
        if {[regexp {commit=([0-9a-f]+)} $line -> c]} {
            set commit $c
        }
        if {[regexp {^PASS:} $line]} {
            set ket_qua PASS
            set sai 0
        } elseif {[regexp {^FAIL: ([0-9]+)/[0-9]+ phep nhan sai} $line -> n]} {
            set ket_qua FAIL
            set sai $n
        } elseif {[regexp {^FAIL: het thoi gian} $line]} {
            set ket_qua TREO
            set sai "-"
        }
    }
    close $handle
    return [list $commit $ket_qua $sai]
}

set files [lsort [glob -nocomplain logs/*.log]]
if {[llength $files] == 0} {
    puts stderr "Khong tim thay file .log trong logs/"
    exit 1
}
puts [format "%-12s %-9s %-8s %s" "File" "Commit" "Ket qua" "Sai"]
set tong 0
foreach f $files {
    lassign [doc_log $f] commit ket_qua sai
    puts [format "%-12s %-9s %-8s %s" [file tail $f] $commit $ket_qua $sai]
    if {[string is integer -strict $sai]} {
        incr tong $sai
    }
}
puts "Tong so phep nhan sai: $tong"