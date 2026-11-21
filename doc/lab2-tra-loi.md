# Lab 2 — Trả lời và bằng chứng thực hành

Repo: `lab-mul-77482403185`. Các kết quả dưới đây được lấy từ năm log mẫu, mã nguồn `rtl/mul16.sv`, testbench và công cụ thực thi trên Ubuntu 24.04 WSL2. Cần tự luyện thao tác để trả lời phần nghiệm thu miệng.

## Phần 1 — Linux

**Q1.** Commit `a1f3c09` bị treo (`run_01.log`), `5be2d14` tính sai (`run_02.log`, `run_03.log`), còn `c7e90aa` tính đúng (`run_04.log`, `run_05.log`). Thông báo timeout gợi ý `req_ready` hoặc `resp_valid` không lên `1` đúng lúc.

**Q2.** Tổng sai là `103 + 88 = 191`. Chỉ có 20 dòng `LOI` vì trong mỗi lần chạy, testbench chỉ `$display` chi tiết khi `errors <= 10` (mỗi log FAIL in tối đa 10 lỗi).

**Q3.** Trong cả 20 lỗi được in, `b` đều có bit 15 bằng `1` (chữ số hex đầu từ `8` đến `f`). Khả năng cao máy trạng thái kết thúc tính trước khi cộng giá trị tương ứng với bit `b[15]`. Đây là phỏng đoán dựa vào log, chưa phải chứng minh từ RTL phiên bản lỗi.

**Q4.** `a=0x0003`, `b=0x8001`: `b mod 0x8000 = 1`, nên `3 × 1 = 3 = 0x00000003`. Giá trị `p` trong hai log lỗi chính là `0x00000003`; giá trị đúng phải là `0x00018003`.

```bash
python3 -c 'print(3*(0x8001%0x8000))'
```

**Q5.** `>` ghi đè nội dung file; `>>` nối tiếp vào cuối file; `2>&1` chuyển luồng lỗi (stderr) vào cùng luồng xuất chuẩn (stdout). Với 20 dòng `LOI`, ghi bằng `>` hai lần vẫn có 20 dòng, còn ghi tiếp bằng `>>` thành 40 dòng.

## Phần 2 — Vim

**Q6.** Đã đối chiếu `rtl/mul16.sv` với bảng cổng trong `doc/dac-ta.md` và sửa sáu nhóm lỗi: (1) dùng `logic` thay cho `wire`/`reg` tại các cổng; (2) tên `reset` → `rst` dòng 14; (3) `a` từ `[W:0]` → `[W-1:0]` dòng 18; (4) thêm dấu phẩy sau cổng `b` dòng 19; (5) `prod` → `p` tại cổng và phép gán; (6) kết quả `p` từ `[W-1:0]` → `[2*W-1:0]` dòng 23.

**Q7.** `:%s/\<prod\>/p/g` chỉ thay từ `prod` nguyên vẹn; dùng `:%s/prod/p/g` có thể đổi cả chuỗi như `prod_count` thành `p_count` ngoài ý muốn.

**Q8.** Với `W=16`, `p` rộng `2W=32` bit. `0xFFFF × 0xFFFF = 0xFFFE0001`. Nếu `p` chỉ rộng 16 bit, phần cao bị bỏ, còn `0x0001`.

**Kiểm tra:** `verilator --lint-only -Wall -Wno-fatal rtl/mul16.sv` không báo `%Error`; `iverilog` biên dịch thành công. Smoke test báo timeout đúng dự kiến vì phần datapath chưa viết (để Lab 5).

## Phần 3 — Git

**Q9.** Repo cá nhân có merge `eef1f8a` từ nhánh `readme`:

```text
*   eef1f8a Merge nhanh readme
|\
| * 5dbdd45 Dien ten va MSSV vao README
|/
* cf9da36 Khoi tao repo tu goi phat, sua khai bao cong mul16
```

Repo giả lập `~/lab2/git-nhom/binh` có lịch sử xung đột:

```text
*   d4d6de5 Gop SUB va AND
|\
| * 3e443ff Binh: them SUB
* | a79b091 An: them AND
|/
* 6c6f610 An: khung ALU
```

**Q10.** Bình đã push cập nhật lên remote trước, khiến nhánh remote có commit mà nhánh của An chưa có. Push của An bị từ chối vì không phải fast-forward. An cần `git pull`, gỡ xung đột, commit và push lại.

**Q11.** `sim/` chứa output mô phỏng sinh ra tự động, không phải mã nguồn; không nên commit. Nếu đã commit: `git rm -r --cached sim`, sau đó commit thay đổi; file vẫn giữ trên ổ đĩa.

**Q12.** Đã thử nhánh `fast-forward-demo`, commit `edcbe3e` và merge vào main *không* có `--no-ff`. Git in `Fast-forward`: main chỉ dịch con trỏ lên commit mới, không tạo merge commit, nên đồ thị tuyến tính. Khác với `eef1f8a` có hai parent do dùng `--no-ff`.

## Phần 4 — Makefile

**Q13.** `make sim-icarus` dùng file đích `sim/tb_mul16_smoke.vvp` phụ thuộc vào RTL/TB. Lần hai, nếu nguồn không đổi thì Make không biên dịch lại; khi `touch rtl/mul16.sv`, nguồn mới hơn đích nên phải biên dịch lại. `sim` là mục tiêu `.PHONY`, gọi lần nào cũng thực hiện lệnh Verilator.

**Q14.** Nếu tồn tại file thực tên `clean` mà không khai báo `.PHONY: clean`, `make clean` có thể xem target đã cập nhật, không chạy lệnh xóa. `.PHONY` buộc luôn thực hiện recipe.

**Q15.** `make trace A=200 B=7 W=8` ghi đè cả ba biến A, B và W. Dùng `?=` để đặt giá trị mặc định nhưng cho phép đối số dòng lệnh thay thế.

**Kiểm tra:** `make lint` có 0 lỗi; `make sim`/`make sim-icarus` biên dịch thành công và timeout dự kiến; `make trace` đúng với `13×11=143`, `0xFFFF×0xFFFF=0xFFFE0001`.

## Phần 5 — Tcl

**Q16.** Khi `w=16`, `puts "W = $w"` in `W = 16`; `puts {W = $w}` in nguyên văn `W = $w`. Dùng `{}` trong biểu thức `expr` và điều kiện `if` để Tcl không thay biến/lệnh quá sớm; `expr` sẽ đánh giá biểu thức số.

**Q17.** Script đã có tùy chọn `--percent` để in cột phần trăm trên 206 phép; dùng `format "%.1f%%" [expr {100.0 * $sai / 206.0}]`.

```bash
tclsh sw/scripts/tong_hop_log.tcl --percent
```

```text
File         Commit    Ket qua  Sai   Ti le
run_01.log   a1f3c09   TREO     -     -
run_02.log   5be2d14   FAIL     103   50.0%
run_03.log   5be2d14   FAIL     88    42.7%
run_04.log   c7e90aa   PASS     0     0.0%
run_05.log   c7e90aa   PASS     0     0.0%
Tong so phep nhan sai: 191
```

**Q18.** Tcl tích hợp trực tiếp với luồng lệnh của các công cụ thiết kế như Yosys, OpenSTA và OpenROAD, giúp tự động hóa việc đọc kết quả, tổng hợp và kiểm tra timing thay vì chỉ ghép lệnh shell.

## Kết luận kiểm tra

- `make logs`: 191 phép nhân sai trên các log mẫu.
- `make lint`: 0 lỗi; cảnh báo UNUSED do module mới có phần khai báo.
- `make sim`/`make sim-icarus`: biên dịch được; smoke test timeout đúng giai đoạn Lab 2.
- Phần hiện thực FSM/datapath chưa làm vì dành cho Lab 5.