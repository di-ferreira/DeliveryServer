unit View.Main.Server;

interface
{(*}
uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Horse,
  Horse.CORS,
  Horse.Exception,
  Horse.Compression,
  Horse.Jhonson,
  Horse.OctetStream,
  Horse.ServerStatic,
  Vcl.StdCtrls,
  Vcl.Mask,
  Vcl.ExtCtrls,
  Vcl.AppEvnts,
  Vcl.Menus,
  Server.Delivery.Controller.Routes;
{*)}

type
  TViewMainServer = class(TForm)
    BtnServer: TButton;
    BtnBot: TButton;
    EdtPorta: TLabeledEdit;
    TrayIcon: TTrayIcon;
    ApplicationEvents: TApplicationEvents;
    PopupMenu: TPopupMenu;
    PPServer: TMenuItem;
    PPBot: TMenuItem;
    procedure BtnServerClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ApplicationEventsMinimize(Sender: TObject);
    procedure TrayIconDblClick(Sender: TObject);
    procedure PPServerClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure CreateServer;
    procedure StartServer;
    procedure StopServer;
    procedure StatusServer;
  public
    { Public declarations }
  end;

var
  ViewMainServer: TViewMainServer;

implementation

{$R *.dfm}

{ TViewMainServer }

procedure TViewMainServer.ApplicationEventsMinimize(Sender: TObject);
begin
  Self.Hide();
  Self.WindowState := TWindowState.wsMinimized;
  TrayIcon.Visible := True;
  TrayIcon.Animate := True;
  TrayIcon.ShowBalloonHint;
end;

procedure TViewMainServer.BtnServerClick(Sender: TObject);
begin
  StatusServer;
end;

procedure TViewMainServer.CreateServer;
begin
  THorse
    .Use(Cors)
    .Use(Compression())
    .Use(Jhonson('UTF-8'));

end;

procedure TViewMainServer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if THorse.IsRunning then
  begin
    StopServer;
  end;
end;

procedure TViewMainServer.FormCreate(Sender: TObject);
begin
  StatusServer;
end;

procedure TViewMainServer.PPServerClick(Sender: TObject);
begin
  StatusServer;
end;

procedure TViewMainServer.StartServer;
begin
  Server.Delivery.Controller.Routes.Registry;
  THorse.Use(ServerStatic(''));

  THorse.Listen(StrToInt(EdtPorta.Text));

  BtnServer.Caption := 'SERVER RUNNING';
  PPServer.Caption := 'SERVER RUNNING';
  EdtPorta.Enabled := False;
end;

procedure TViewMainServer.StatusServer;
begin
  if THorse.IsRunning then
    StopServer
  else
    StartServer;
end;

procedure TViewMainServer.StopServer;
begin
  THorse.StopListen;
  BtnServer.Caption := 'SERVER STOPED';
  PPServer.Caption := 'SERVER STOPED';
  EdtPorta.Enabled := True;
end;

procedure TViewMainServer.TrayIconDblClick(Sender: TObject);
begin
  TrayIcon.Visible := False;
  Show();
  WindowState := TWindowState.wsNormal;
  Application.BringToFront();
end;

end.

