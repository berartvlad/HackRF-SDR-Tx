unit radio;
interface
uses uHackrf, Dialogs, forms, Windows;
type
  ar=array of Byte;
  TRXTXFunc=procedure;
var
  a:^ar;
  flag:Boolean;
  BufferLength:LongWord;
  NByteTX:LongWord;
  alpha:Real;
  iq:Byte;
  FreqCenter:LongWord;
  GainLna:Byte;
  GainVga:Byte;
  Amp:Boolean;
  SampleRate:LongWord;
  HackRFStarted:Boolean;
  RXTX:TRXTXFunc;
  amplitude:Real;
  sound:array of Byte;
  SizeSound:LongWord;
  ch:Real;
  NSoundTX:LongWord;
  TXSamles:array of Byte;
  NTXsamle:LongWord;
  shFreq:Real;
  dev:Real;
  bandwidth_hz1, bandwidth_hz2, bandwidth_hz3:UInt32;
  FRX:hackrf_sample_block_cb_fn;
  TXCfg:Pointer;
  HackRFDevice:phackrf_device;
function StartHackTX(FRX:TRXTXFunc):Integer;
function StopHackRF:Integer;
procedure SetShiftFreq(freq:Longint);
function tx(transfer: phackrf_transfer): Integer;  cdecl//Обработчик для заполнения буфера при передаче
implementation

uses SysUtils;
procedure SetShiftFreq(freq:LongInt);
begin
  shFreq:=freq/1000;
end;

function rx(transfer: phackrf_transfer): Integer;  cdecl
begin
  BufferLength:=transfer.buffer_length;
  a:=@transfer.buffer;
  RXTX;
  Result:=0;
end;
function tx(transfer: phackrf_transfer): Integer;  cdecl
var al:Real;
  i, j, n:Integer;
begin
  BufferLength:=transfer.buffer_length;
  a:=@transfer.buffer;
//////////////////////формирование и модулирование
  for i := 0 to (BufferLength-1) div 2 do begin
    alpha:=(alpha+shFreq);
    NSoundTX:=Round(NTXsamle/ch) mod SizeSound;
    al:=alpha+dev*(sound[NSoundTX]-127);
    a^[2*i]:=round(cos(al+pi/2)*(amplitude{+((sound[NSoundTX]))/5)}));
    a^[2*i+1]:=round(cos(al)*(amplitude{+((sound[NSoundTX]))/5)}));
    inc(NTXsamle);
  end;
///////////////////////////////////////////////////
  Result:=0;
end;
function StartHackTX(FRX:TRXTXFunc):Integer;
begin
  Result:=hackrf_init;
  if (Result<>0) then
  begin
    ShowMessage('hackrf_init<>0');
    Exit;
  end;
  Result:=hackrf_open(HackRFDevice);
  if Result<>0 then
  begin
    ShowMessage('OpenHackRFDevice<>0');
    Exit;
  end;
  hackrf_set_freq(HackRFDevice, FreqCenter);
  hackrf_set_lna_gain(HackRFDevice, GainLna);
  hackrf_set_vga_gain(HackRFDevice, GainVga);
  hackrf_set_amp_enable(HackRFDevice, Byte(amp));
  hackrf_set_sample_rate(HackRFDevice,SampleRate);
  hackrf_set_baseband_filter_bandwidth(HackRFDevice, 1750000);
  Result:=hackrf_start_tx(HackRFDevice, tx, Application);
  if Result<>0 then
  begin
    ShowMessage('hackrf_start_rx<>0');
    Exit;
  end;
end;

function StopHackRF:Integer;

begin
  Result:=hackrf_stop_rx(HackRFDevice);
  Result:=hackrf_close(HackRFDevice);
  Result:=hackrf_exit;
end;
initialization
  FreqCenter:=433000000;
  GainLna:=20;
  GainVga:=10;
  Amp:=False;
  SampleRate:=8000000;
  SetLength(sound,2048);
  HackRFStarted:=False;
  shFreq:=0;
  amplitude:=10;
  iq:=1;
  SetLength(TXSamles, SampleRate*2);
  dev:=0.03;
end.
