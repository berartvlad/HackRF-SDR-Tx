unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uHackrf, StdCtrls, radio, ComCtrls, WavRec, MMSystem, math,
  ExtCtrls, INIFILEs, Buttons;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    TrackBar1: TTrackBar;
    TrackBar2: TTrackBar;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Timer1: TTimer;
    Timer2: TTimer;
    TrackBar3: TTrackBar;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer2Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TrackBar3Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure OnWaveIn(var Msg: TMessage); message MM_WIM_DATA;
  end;

var
  Form1: TForm1;
  trans:Boolean;//флаг передачи/приема
  SDRSharpFRX:hackrf_sample_block_cb_fn;//Обработчик SDRSharpа принятых данных
  IniFile:TIniFile;
  PathINI:string;

implementation

{$R *.dfm}
procedure TForm1.OnWaveIn;
var i:LongWord;
  b:ShortInt;
begin
  if stop then
    exit;
  CopyMemory(sound,PData8(PWaveHdr(Msg.lParam)^.lpData),BufSize);
  NTXsamle:=0;//Номер элемента массива со звуком, с которого начинает отправку
  WaveInAddBuffer(WaveIn, PWaveHdr(Msg.lParam), SizeOf(TWaveHdr));
end;

procedure processing;
begin
  //Здесь может быть дополнительный обработчик при отправке
end;
procedure TForm1.Button1Click(Sender: TObject);
begin //Переход в режим передачи
  if not flag then Exit; //Если еще не запущен SDR#.(Прием в SDR# должен быть вкл.)
  if HackRFDevice<>nil then begin //Останавливаем прием, если он был запущен
    try
      StopHackRF;
    except
    end;
  end;
  NTXsamle:=0;
  ch:=SampleRate/22050;//Используется при формировании сигнала перед отправкой
  SizeSound:=22050 div 2;//Размер буфера звука
  SetLength(sound, SizeSound);
  startrec(Form1.Handle);//Запуск микрофона
  StartHackTX(processing);//Запуск передачи
end;

procedure TForm1.Button2Click(Sender: TObject);
var Result:Integer;
begin //Запуск приема
  if not flag then Exit;//Если еще не запущен SDR#.(Прием в SDR# должен быть вкл.)
  StopRec;//Выключаем микрофон
  if HackRFDevice<>nil then begin//Останавливаем HachRF, если запущен
    try
      StopHackRF;
    except
    end;
  end;
  Result:=hackrf_init;//Заново запускаем HackRF
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
  hackrf_set_freq(HackRFDevice, FreqCenter); //Установка частоты, усиления и пр.
  hackrf_set_lna_gain(HackRFDevice, GainLna);
  hackrf_set_vga_gain(HackRFDevice, GainVga);
  hackrf_set_amp_enable(HackRFDevice, integer(amp));
  hackrf_set_sample_rate(HackRFDevice,SampleRate);
  hackrf_compute_baseband_filter_bw_round_down_lt(bandwidth_hz1);
  hackrf_compute_baseband_filter_bw(bandwidth_hz2);
  hackrf_set_baseband_filter_bandwidth(HackRFDevice,bandwidth_hz3);
  hackrf_is_streaming(HackRFDevice);
  SDRSharpFRX:=FRX;
  Result:=hackrf_start_rx(HackRFDevice, FRX, TXCfg);
  if Result<>0 then
  begin
    ShowMessage('hackrf_start_rx<>0');
    Exit;
  end;
  HackRFStarted:=True;
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
var
  mnozh:Integer;
begin //Смещение частоты от центральной
  mnozh:=Round(15.9*(SampleRate div 100000));
  SetShiftFreq(((TrackBar1.Position-500)*4));
  Label3.Caption:=inttostr((FreqCenter+((TrackBar1.Position-500)*4)*mnozh));
end;

procedure TForm1.TrackBar2Change(Sender: TObject);
begin
  dev:=TrackBar2.Position/100;//Установка девиации для FM
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if @SDRSharpFRX<>nil then
    FRX:=SDRSharpFRX;//Обработчик принятых данных возвращаем на место (SDRSharp)
  StopRec;//Вырубаем микрофон
  IniFile.WriteInteger('PARAMETERS', 'POWER', TrackBar3.Position);
  IniFile.WriteInteger('PARAMETERS', 'DEVIATION', TrackBar2.Position);
  IniFile.WriteInteger('PARAMETERS', 'ShiftFreq', TrackBar1.Position);
end;

procedure TForm1.Timer2Timer(Sender: TObject);
begin //Ожидание нажатия на ctrl
  if (getasynckeystate(VK_LCONTROL)<>0) then begin
    if not trans then begin
      trans:=True;
      Button1Click(Sender);//Если нажата, то перевожим в режим передачи
      if flag then Label5.Font.Color:=clRed;
    end;
  end
  else begin
    if trans then begin
      form1.Caption:='rx';
      trans:=False;
      Button2Click(Sender);//Если отпустили, то перевожим в режим приема
      Label5.Font.Color:=clGreen;
    end;
  end;
end;
procedure TForm1.FormCreate(Sender: TObject);
var stv:string;
begin
  trans:=False;
  @SDRSharpFRX:=nil;
  PathINI:=extractfilepath(application.ExeName)+'HackRFTX.INI';
  if FileExists(pathINI) then begin
    IniFile:=TIniFile.Create(pathINI);
    TrackBar3.Position:=IniFile.readInteger('PARAMETERS', 'POWER', 0);
    TrackBar2.Position:=IniFile.readInteger('PARAMETERS', 'DEVIATION', 0);
    TrackBar1.Position:=IniFile.readInteger('PARAMETERS', 'ShiftFreq', 0);
  end;
  TrackBar1Change(Sender);
  TrackBar2Change(Sender);
  TrackBar3Change(Sender);
end;

procedure TForm1.TrackBar3Change(Sender: TObject);
begin
  amplitude:=TrackBar3.Position;//Амплитуда синусойды, отправляемого на устройство
  //эта амплитуда влияет на мощность выдаваемого сигнала
end;

end.
