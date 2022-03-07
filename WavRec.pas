unit WavRec;

interface
uses MMSystem, Types, Forms, SysUtils, Windows, radio;
type
  TData8 = array [0..127] of byte;
  PData8 = ^TData8;

  TPointArr = array [0..127] of TPoint;
  PPointArr = ^TPointArr;

  PWaveHeader = ^TWaveHeader;
  TWaveHeader = packed record
    idRiff        : array [0..3] of Char;
    RiffLen       : LongInt;
    idWave        : Array[0..3] of Char;
    idFmt         : Array[0..3] of Char;
    InfoLen       : LongInt;
    FormatTag     : Word;
    Channels      : Word;
    Freq          : LongInt;
    BytesPerSec   : LongInt;
    BlockAlign    : Word;
    BitsPerSample : Word;
    idData        : Array[0..3] of Char;
    DataBytes     : LongInt;
  end;
var
    FWaveDataSize: dword;
    WaveF: integer;
    BufLen: integer;  WaveIn: hWaveIn;
  hBuf: THandle;
  BufHead1, BufHead2: TWaveHdr;
  bufsize: integer;
  Bits16: boolean;
  p: PPointArr;
  stop: boolean = true;
  hheader: TWaveFormatEx;
  buf1, buf2: pointer;
  NByteRec:LongWord;
function StartRec (Handle:THandle):Integer;
function StopRec:Integer;
function  WriteWaveBuffer(F: integer; const Buffer; Count: integer): integer;
implementation
function StartRec (Handle:THandle):Integer;
begin
  BufSize := SizeSound;
  with hheader do begin
    wFormatTag := WAVE_FORMAT_PCM;
    nChannels := 1;
    nSamplesPerSec := 22050;//44100; //
    wBitsPerSample := 8;
    nBlockAlign := nChannels * (wBitsPerSample div 8);
    nAvgBytesPerSec := nSamplesPerSec * nBlockAlign;
    cbSize := 0;
  end;
  WaveInOpen(Addr(WaveIn), WAVE_MAPPER, addr(hheader),Handle, 0, CALLBACK_WINDOW);
  BufLen := hheader.nBlockAlign * BufSize;
  GetMem(buf1, BufLen);
  GetMem(buf2, BufLen);
  FillChar(BufHead1, SizeOf(BufHead1), 0);
  BufHead1.lpData := Buf1;
  BufHead1.dwBufferLength := BufLen;
  FillChar(BufHead2, SizeOf(BufHead2), 0);
  BufHead2.lpData := Buf2;
  BufHead2.dwBufferLength := BufLen;

  WaveInPrepareHeader(WaveIn, Addr(BufHead1), sizeof(BufHead1));
  WaveInAddBuffer(WaveIn, addr(BufHead1), sizeof(BufHead1));
  WaveInPrepareHeader(WaveIn, Addr(BufHead2), sizeof(BufHead2));
  WaveInAddBuffer(WaveIn, addr(BufHead2), sizeof(BufHead2));

  GetMem(p, BufSize * sizeof(TPoint));
  stop := false;
  WaveInStart(WaveIn);

end;
function StopRec:Integer;
begin
  if stop then
    Exit;
  stop := true;
  WaveInReset(WaveIn); // ????? WaveInReset ?????? ????????????? ? ????????? ??????? OnWaveIn
  WaveInUnPrepareHeader(WaveIn, addr(BufHead1), sizeof(BufHead1));
  WaveInUnPrepareHeader(WaveIn, addr(BufHead2), sizeof(BufHead2));
  WaveInClose(WaveIn);
  FreeMem(buf1);
  FreeMem(buf2);
  FreeMem(p, BufSize * sizeof(TPoint));
end;

function  CreateWaveFile(FileName: string; afreq, achans, abps: Dword): integer;
var
  header: TWaveHeader;
begin
  FWaveDataSize := 0;
  FillChar(header, SizeOf(header), 0);
  header.idRiff := 'RIFF';
  header.idWave := 'WAVE';
  header.idFmt := 'fmt ';
  header.InfoLen := 16;
  header.FormatTag := 1;
  header.Channels := achans;
  header.Freq := afreq;
  header.BytesPerSec := (abps div 8) * achans * afreq;
  header.BlockAlign := (abps div 8) * achans;
  header.BitsPerSample := abps;
  header.idData := 'data';

  Result := FileCreate(FileName);
  if Result <> INVALID_HANDLE_VALUE then
    FileWrite(Result, header, SizeOf(header));
end;
function  WriteWaveBuffer(F: integer; const Buffer; Count: integer): integer;
begin
  Result := FileWrite(F, Buffer, Count);
  FWaveDataSize := FWaveDataSize + Count;
end;
initialization
end.
