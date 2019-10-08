unit abox;

interface

uses Windows,StdCtrls,Forms,Controls,ExtCtrls,
Classes,SysUtils, VersInfo;

type
  TAboutBox = class(TForm)
    ProgramIcon: TImage;
    ProgramName: TLabel;
    VersionCAP: TLabel;
    Copyright: TLabel;
    Comments: TLabel;
    OkBtn: TButton;
    RightsCAP: TLabel;
    okvir: TBevel;
    panel: TPanel;
    VrzCAP: TLabel;
    InfoCAP: TLabel;
    EMAILED: TEdit;
    EMAILCAP: TLabel;
    VersionInfo: TVersionInfoResource;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

procedure ShowAboutBox;

implementation

{$R *.DFM}

procedure ShowAboutBox;
begin
  with TAboutBox.Create(Application) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TAboutBox.FormCreate(Sender: TObject);
begin
 Caption := Format('About %s', [Application.Title]);
 ProgramIcon.Picture.Assign(Application.Icon);
 ProgramName.Caption := Application.Title;
 VersionCAP.Caption := 'Build ' + inttostr(VersionInfo.FileVersion.Build);
end;

procedure TAboutBox.FormShow(Sender: TObject);
begin
ActiveControl := OkBtn;
end;


end.

