unit JPGOpts;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls;

type
  TJPEGOptions = class(TForm)
    decap: TLabel;
    Bevel1: TBevel;
    odustani: TButton;
    Dobro: TButton;
    GroupBox1: TGroupBox;
    JPEGInOriginalRadioButton: TRadioButton;
    JPEGIn256RadioButton: TRadioButton;
    JPEGInGrayRadioButton: TRadioButton;
    quantgrp: TGroupBox;
    JPEGIn1PassRadioButton: TRadioButton;
    JPEGIn2PassRadioButton: TRadioButton;
    dthrgrp: TGroupBox;
    JPEGInNoDitherRadioButton: TRadioButton;
    JPEGInOrdDitherRadioButton: TRadioButton;
    JPEGInFSDitherRadioButton: TRadioButton;
    dekodcap: TLabel;
    nvcap: TLabel;
    defaults: TButton;
    JPGQualText: TEdit;
    JPGOutQuality: TUpDown;
    procedure FormActivate(Sender: TObject);
    procedure JPEGInOriginalRadioButtonClick(Sender: TObject);
    procedure JPEGIn256RadioButtonClick(Sender: TObject);
    procedure JPEGInGrayRadioButtonClick(Sender: TObject);
    procedure DobroClick(Sender: TObject);
    procedure defaultsClick(Sender: TObject);
    procedure JPGQualTextChange(Sender: TObject);
  private
    { Private-Declarations }
  public
    { Public-Declarations }
  end;

var
  JPEGOptions: TJPEGOptions;

implementation

uses Bpr;

{$R *.DFM}

procedure TJPEGOptions.FormActivate(Sender: TObject);
begin
  JPGOutQuality.Position := JPEG_Out_Quality;
  {------------- Dither-Option}
  case JPEG_In_Dither of
       tDit_No   : JPEGInNoDitherRadioButton.Checked  := true;
       tDit_Ord  : JPEGInOrdDitherRadioButton.Checked := true;
       tDit_FS   : JPEGInFSDitherRadioButton.Checked  := true;
  end;
  {------------- Pass-Quantising}
  case JPEG_In_2Pass of
       false     : JPEGIn1PassRadioButton.Checked := true;
       true      : JPEGIn2PassRadioButton.Checked := true;
  end;
  {------------- Dithering}
  case JPEG_In_OutColors of
       tCol_No   : begin
                     JPEGInOriginalRadioButton.Checked  := true;
                     JPEGInNoDitherRadioButton.Enabled  := false;
                     JPEGInOrdDitherRadioButton.Enabled := false;
                     JPEGInFSDitherRadioButton.Enabled  := false;
                     JPEGIn1PassRadioButton.Enabled     := false;
                     JPEGIn2PassRadioButton.Enabled     := false;
                   end;

       tCol_256  : begin
                     JPEGIn256RadioButton.Checked := true;
                     JPEGInNoDitherRadioButton.Enabled := true;
                     JPEGInOrdDitherRadioButton.Enabled := true;
                     JPEGInFSDitherRadioButton.Enabled := true;
                     JPEGIn1PassRadioButton.Enabled := true;
                     JPEGIn2PassRadioButton.Enabled := true;
                   end;
       tCol_Gray : begin
                     JPEGInGrayRadioButton.Checked := true;
                     JPEGInNoDitherRadioButton.Enabled := false;
                     JPEGInOrdDitherRadioButton.Enabled := false;
                     JPEGInFSDitherRadioButton.Enabled := false;
                     JPEGIn1PassRadioButton.Enabled := false;
                     JPEGIn2PassRadioButton.Enabled := false;
                   end;
  end;
end;

procedure TJPEGOptions.JPEGInOriginalRadioButtonClick(Sender: TObject);
begin
  JPEGInNoDitherRadioButton.Enabled := false;
  JPEGInOrdDitherRadioButton.Enabled := false;
  JPEGInFSDitherRadioButton.Enabled := false;
  JPEGIn1PassRadioButton.Enabled := false;
  JPEGIn2PassRadioButton.Enabled := false;
end;

procedure TJPEGOptions.JPEGIn256RadioButtonClick(Sender: TObject);
begin
  JPEGInNoDitherRadioButton.Enabled := true;
  JPEGInOrdDitherRadioButton.Enabled := true;
  JPEGInFSDitherRadioButton.Enabled := true;
  JPEGIn1PassRadioButton.Enabled := true;
  JPEGIn2PassRadioButton.Enabled := true;
end;

procedure TJPEGOptions.JPEGInGrayRadioButtonClick(Sender: TObject);
begin
  JPEGInNoDitherRadioButton.Enabled := false;
  JPEGInOrdDitherRadioButton.Enabled := false;
  JPEGInFSDitherRadioButton.Enabled := false;
  JPEGIn1PassRadioButton.Enabled := false;
  JPEGIn2PassRadioButton.Enabled := false;
end;

procedure TJPEGOptions.DobroClick(Sender: TObject);
begin
  JPEG_Out_Quality := JPGOutQuality.Position;
  {------------- Dither-Option}
  if JPEGInNoDitherRadioButton.Checked
  then JPEG_In_Dither := tDit_No
  else if JPEGInOrdDitherRadioButton.Checked
  then JPEG_In_Dither := tDit_Ord
  else JPEG_In_Dither := tDit_FS;
  {------------- Pass-Quantising}
  if JPEGIn1PassRadioButton.Checked
  then JPEG_In_2Pass := false
  else JPEG_In_2Pass := true;
  {------------- Dithering}
  if JPEGInOriginalRadioButton.Checked
  then JPEG_In_OutColors := tCol_No
  else if JPEGIn256RadioButton.Checked
  then JPEG_In_OutColors := tCol_256
  else JPEG_In_OutColors := tCol_Gray;
end;

procedure TJPEGOptions.defaultsClick(Sender: TObject);
begin
projectb.SetJPEGDefaults;
JPEGOptions.FormActivate(Sender);
end;

procedure TJPEGOptions.JPGQualTextChange(Sender: TObject);
begin
if JPGQualText.Text = '' then
   JPGOutQuality.Position := 0;
end;

end.
