{ *********************************************************************** }
{                                                                         }
{ Delphi  Library                                                         }
{ Промежуточный слой, между SDRHarp и HackRF.DLL                          }
{                                                                         }
{ BerArtVlad@mail.ru                                                      }
{                                                                         }
{ *********************************************************************** }

library hackrf;

uses
  radio, Dialogs, forms,
  SysUtils,  Classes,
  uHackrf,//Оболочка над стандартной библиотекой HackRF.DLL
  Unit1 in 'Unit1.pas' {Form1};

{$R *.res}
function hackrf_init(): Integer; cdecl; export;
begin
  if Unit1.form1=nil then Unit1.form1:=Unit1.TForm1.Create(nil);
  Unit1.form1.Show;
  Form1.FormStyle := fsStayOnTop;
  Result:=uHackrf.hackrf_init();
end;
function hackrf_exit(): Integer; cdecl; export;
var
  ev:TCloseAction;
begin
  Result:=uHackrf.hackrf_exit();
  Form1.FormClose(nil, ev);
end;
function hackrf_open(var device: phackrf_device): Integer; cdecl; export;
begin
  Result:=uHackrf.hackrf_open(device);
  HackRFDevice:=device;
end;
function hackrf_close(device: phackrf_device): Integer; cdecl; export;
begin
  form1.Timer1.Enabled:=False;
  try
    Result:=uHackrf.hackrf_close(HackRFDevice);
  except
  end;
end;

function hackrf_start_rx(device: phackrf_device; callback: hackrf_sample_block_cb_fn; rx_ctx: Pointer): Integer; cdecl; export;
begin
  Result:=uHackrf.hackrf_start_rx(HackRFDevice, callback, rx_ctx);
  TXCfg:=rx_ctx;
  FRX:=callback;
  flag:=True;
end;
function hackrf_stop_rx(device: phackrf_device): Integer; cdecl; export;
begin
  Result:=uHackrf.hackrf_stop_rx(HackRFDevice);
  form1.Timer1.Enabled:=True;
end;

function hackrf_start_tx(device: phackrf_device; callback: hackrf_sample_block_cb_fn; tx_ctx: Pointer): Integer; cdecl; export;
begin
  Result:=uHackrf.hackrf_start_tx(HackRFDevice, callback, tx_ctx);
  FRX:=callback;
  TXCfg:=tx_ctx;
end;
function hackrf_stop_tx(device: phackrf_device): Integer; cdecl; export;
begin
  Result:=uHackrf.hackrf_stop_tx(HackRFDevice);
end;

function hackrf_is_streaming(device: phackrf_device): Integer; cdecl;  export;
begin
  Result:=uHackrf.hackrf_is_streaming(HackRFDevice);
end;

function hackrf_max2837_read(device: phackrf_device; register_number: Byte; value: PWord): Integer; cdecl; export;
begin
  Result:=uHackrf.hackrf_max2837_read(HackRFDevice, register_number, value);
end;
function hackrf_max2837_write(device: phackrf_device; register_number: Byte; value: Word): Integer; cdecl; export;
begin
  Result:=uHackrf.hackrf_max2837_write(HackRFDevice, register_number, value);
end;

function hackrf_si5351c_read(device: phackrf_device; register_number: Word; value: PWord): Integer; cdecl; export;
begin
  Result:=uHackrf.hackrf_si5351c_read(HackRFDevice, register_number, value);
end;
function hackrf_si5351c_write(device: phackrf_device; register_number: Word; value: Word): Integer; cdecl; export;
begin
  Result:=uHackrf.hackrf_si5351c_write(HackRFDevice, register_number, value);
end;

function hackrf_set_baseband_filter_bandwidth(device: phackrf_device; const bandwidth_hz: UInt32): Integer; cdecl; export;
begin

  Result:=uHackrf.hackrf_set_baseband_filter_bandwidth(HackRFDevice, bandwidth_hz);
end;

function hackrf_rffc5071_read(device: phackrf_device; register_number: Word; value: PWord): Integer; cdecl; export;
begin
  Result:=uHackrf.hackrf_rffc5071_read(HackRFDevice, register_number, value);
end;
function hackrf_rffc5071_write(device: phackrf_device; register_number: Word; value: Word): Integer; cdecl; export;
begin
  Result:=uHackrf.hackrf_rffc5071_write(HackRFDevice, register_number, value);
end;

function hackrf_spiflash_erase(device: phackrf_device): Integer; cdecl; export;
begin
  Result:=uHackrf.hackrf_spiflash_erase(HackRFDevice);
end;
function hackrf_spiflash_write(device: phackrf_device; const address: UInt32; const length: Word; const data: PByte): Integer; cdecl; export;
begin
  Result:=uHackrf.hackrf_spiflash_write(HackRFDevice, address, length, data);
end;
function hackrf_spiflash_read(device: phackrf_device; const address: UInt32; const length: Word; data: PByte): Integer; cdecl; export;
begin
  Result:=uHackrf.hackrf_spiflash_read(HackRFDevice, address, length, data);
end;
function hackrf_cpld_write(device: phackrf_device; const data: PByte; const total_length: UInt32): Integer; cdecl; export;
begin
  Result:=uHackrf.hackrf_cpld_write(HackRFDevice, data, total_length);
end;

function hackrf_board_id_read(device: phackrf_device; value: PByte): Integer; cdecl; export;
begin
  Result:=uHackrf.hackrf_board_id_read(HackRFDevice, value);
end;
function hackrf_version_string_read(device: phackrf_device; version: PAnsiChar; length: Byte): Integer; cdecl; export;
begin
  Result:=uHackrf.hackrf_version_string_read(HackRFDevice, version, length);
end;

function hackrf_set_freq(device: phackrf_device; const freq_hz: UInt64): Integer; cdecl; export;
begin
  FreqCenter:=freq_hz;
  Form1.Label2.Caption:='Центральная частота: '+IntToStr(freq_hz);
  Result:=uHackrf.hackrf_set_freq(HackRFDevice, freq_hz);
  Form1.TrackBar1Change(nil);

end;
function hackrf_set_freq_explicit(device: phackrf_device; const if_freq_hz: UInt64;
  const lo_freq_hz: UInt64; path: rf_path_filter): Integer; cdecl; export;
begin
  Result:=uHackrf.hackrf_set_freq_explicit(HackRFDevice, if_freq_hz, lo_freq_hz, path);
end;

function hackrf_set_sample_rate_manual(device: phackrf_device; const freq_hz: UInt32; const divider: UInt32): Integer; cdecl; export;
begin
  Result:=uHackrf.hackrf_set_sample_rate_manual(HackRFDevice, freq_hz, divider);
end;
function hackrf_set_sample_rate(device: phackrf_device; const freq_hz: Double): Integer; cdecl; export;
begin
  SampleRate:=Round(freq_hz);
  Result:=uHackrf.hackrf_set_sample_rate(HackRFDevice, freq_hz);
end;

function hackrf_set_amp_enable(device: phackrf_device; value: Byte): Integer; cdecl; export;
begin
  Amp:=Boolean(value);
  Result:=uHackrf.hackrf_set_amp_enable(HackRFDevice, value);
end;

function hackrf_board_partid_serialno_read(device: phackrf_device; read_partid_serialno: pread_partid_serialno_t): Integer; cdecl; export;
begin
  Result:=uHackrf.hackrf_board_partid_serialno_read(HackRFDevice, read_partid_serialno);
end;

function hackrf_set_lna_gain(device: phackrf_device; value: UInt32): Integer; cdecl; export;
begin
  GainLna:=value;
  Result:=uHackrf.hackrf_set_lna_gain(HackRFDevice, value);
end;

function hackrf_set_vga_gain(device: phackrf_device; value: UInt32): Integer; cdecl; export;
begin
  GainVga:=value;
  Result:=uHackrf.hackrf_set_vga_gain(HackRFDevice, value);
end;

function hackrf_set_txvga_gain(device: phackrf_device; value: UInt32): Integer; cdecl; export;
begin
  amp:=Boolean(value);
  Result:=uHackrf.hackrf_set_txvga_gain(HackRFDevice, value);
end;

function hackrf_set_antenna_enable(device: phackrf_device; const value: Byte): Integer; cdecl; export;
begin
  Result:=uHackrf.hackrf_set_antenna_enable(HackRFDevice, value);
end;

function hackrf_error_name(errcode: hackrf_error): PAnsiChar; cdecl; export;
begin
  Result:=uHackrf.hackrf_error_name(errcode);
end;
function hackrf_board_id_name(board_id: hackrf_board_id): PAnsiChar; cdecl; export;
begin
  Result:=uHackrf.hackrf_board_id_name(board_id);
end;
function hackrf_filter_path_name(const path: rf_path_filter): PAnsiChar; cdecl; export;
begin
  Result:=uHackrf.hackrf_filter_path_name(path);
end;

function hackrf_compute_baseband_filter_bw_round_down_lt(const bandwidth_hz: UInt32): UInt32; cdecl; export;
begin
  Result:=uHackrf.hackrf_compute_baseband_filter_bw_round_down_lt(bandwidth_hz);
  bandwidth_hz1:=bandwidth_hz;
end;

function hackrf_compute_baseband_filter_bw(const bandwidth_hz: UInt32): UInt32; cdecl; export;
begin
  Result:=uHackrf.hackrf_compute_baseband_filter_bw(bandwidth_hz);
  bandwidth_hz2:=bandwidth_hz;
end;



exports
hackrf_init,
hackrf_exit,
hackrf_open,
hackrf_close,
hackrf_start_rx,
hackrf_stop_rx,
hackrf_start_tx,
hackrf_stop_tx,
hackrf_is_streaming,
hackrf_max2837_read,
hackrf_max2837_write,
hackrf_si5351c_read,
hackrf_si5351c_write,
hackrf_set_baseband_filter_bandwidth,
hackrf_rffc5071_read,
hackrf_rffc5071_write,
hackrf_spiflash_erase,
hackrf_spiflash_write,
hackrf_spiflash_read,
hackrf_cpld_write,
hackrf_board_id_read,
hackrf_version_string_read,
hackrf_set_freq,
hackrf_set_freq_explicit,
hackrf_set_sample_rate_manual,
hackrf_set_sample_rate,
hackrf_set_amp_enable,
hackrf_board_partid_serialno_read,
hackrf_set_lna_gain,
hackrf_set_vga_gain,
hackrf_set_txvga_gain,
hackrf_set_antenna_enable,
hackrf_error_name,
hackrf_board_id_name,
hackrf_filter_path_name,
hackrf_compute_baseband_filter_bw_round_down_lt,
hackrf_compute_baseband_filter_bw;
begin
end.
