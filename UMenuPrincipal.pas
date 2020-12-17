unit UMenuPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  //** Componentes para whatsapp **//
  uTInject.ConfigCEF, uTInject,            uTInject.Constant,      uTInject.JS,     uInjectDecryptFile,
  uTInject.Console,   uTInject.Diversos,   uTInject.AdjustNumber,  uTInject.Config, uTInject.Classes,
  //**//
  Vcl.StdCtrls, Vcl.Imaging.GIFImg, Vcl.ExtCtrls, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.Imaging.pngimage, UBDados,
  Vcl.AppEvnts, UFuncoes;

type
  TPrincipal = class(TForm)
    Inject: TInject;
    LblStatus: TLabel;
    Tempo: TTimer;
    Whatsapp: TFDQuery;
    BtnConexao: TButton;
    QtdeMsgs: TLabel;
    LblQtde: TLabel;
    Image1: TImage;
    Bandeja: TTrayIcon;
    Eventos: TApplicationEvents;
    GroupBox1: TGroupBox;
    DDI: TEdit;
    DDD: TEdit;
    Telefone: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    BtnEnviar: TButton;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure InjectDisconnectedBrute(Sender: TObject);
    procedure InjectIsConnected(Sender: TObject; Connected: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure InjectGetStatus(Sender: TObject);
    procedure TempoTimer(Sender: TObject);
    procedure BtnConexaoClick(Sender: TObject);
    procedure EventosMinimize(Sender: TObject);
    procedure BandejaDblClick(Sender: TObject);
    procedure BtnEnviarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    WhatsappConectado : Boolean;
    procedure IniciarEnvios;
  end;

var
  Principal: TPrincipal;

implementation

{$R *.dfm}

procedure TPrincipal.BandejaDblClick(Sender: TObject);
begin
   Bandeja.Visible := False;
   Show();
   WindowState := wsNormal;
   Application.BringToFront();
end;

procedure TPrincipal.BtnConexaoClick(Sender: TObject);
begin
   if not WhatsappConectado then
      begin
        if not Inject.Auth(false) then
           Begin
              Inject.FormQrCodeType := TFormQrCodeType(0);
              Inject.FormQrCodeStart;
           End;

        if not Inject.FormQrCodeShowing then
           Inject.FormQrCodeShowing := True;
      end
   else
      begin
         if not Inject.auth then
            exit;

         Inject.Logtout;
         Inject.Disconnect;
      end;
end;

procedure TPrincipal.BtnEnviarClick(Sender: TObject);
var
   numero, mensagem: string;
begin
   numero := DDD.Text + telefone.Text;
   mensagem := Memo1.Lines.Text;
   Inject.send(Numero, mensagem);
end;

procedure TPrincipal.EventosMinimize(Sender: TObject);
begin
  Self.Hide();
  Self.WindowState := wsMinimized;
  Bandeja.Visible := True;
  Bandeja.Animate := True;
  Bandeja.BalloonTitle := 'Mensagens';
  Bandeja.BalloonHint := 'O aplicativo está minimizado aqui';
  Bandeja.ShowBalloonHint;
end;

procedure TPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   Inject.ShutDown;
end;

procedure TPrincipal.FormCreate(Sender: TObject);
var
   I: Integer;
begin
   ReportMemoryLeaksOnShutdown  := false;
end;

procedure TPrincipal.IniciarEnvios;
var
   Numero, Texto : String;
begin
   Tempo.enabled := false;
   if WhatsappConectado then
      begin
         Tempo.Interval := 8000;
         BtnConexao.Caption := 'Desconectar';
         if BDados.BDados.Connected then
            begin
               with BDados.Pesquisa do
                  begin
                     Close;
                     sql.Clear;
                     sql.Add('select count(codigo) as qtde from whatsapp where dataenviar <= CURRENT_TIMESTAMP and DATAENVIADO IS NULL');
                     Open;
                     LblQtde.Caption := Fieldbyname('qtde').AsString;
                  end;
               if BDados.Pesquisa.FieldByName('qtde').AsInteger > 0 then
                  begin
                     with Whatsapp do
                        begin
                           Close;
                           SQL.Clear;
                           SQL.Add('SELECT * FROM whatsapp WHERE DATAENVIADO IS NULL AND dataenviar <= CURRENT_TIMESTAMP ');
                           Open;
                           Numero := Fieldbyname('ddd').AsString + SomenteNumeros(Fieldbyname('telefone').AsString);
                           Texto  := FieldByName('mensagem').AsString;
                           if not eof then
                              begin
                                 try
                                    if not Inject.Auth then
                                       Exit;

                                    Inject.send(Numero, Texto);
                                 Except on
                                    e:exception do
                                       begin
                                          //ShowMessage(e.message);
                                          Tempo.Enabled := True;
                                          Abort;
                                       end;
                                 end;
                                 BDados.Outros.Close;
                                 BDados.Outros.SQL.Clear;
                                 BDados.Outros.SQL.Add('update whatsapp set dataenviado = current_timestamp '+
                                                       ' where codigo = :codigo and empresa = :empresa      ');
                                 BDados.Outros.Parambyname('Codigo').AsInteger  := Whatsapp.FieldByName('codigo').AsInteger;
                                 BDados.Outros.ParamByName('Empresa').AsInteger := Whatsapp.FieldByName('empresa').AsInteger;
                                 BDados.Outros.ExecSQL;
                              end;

                        end;
                  end;
            end;
      end
   else
      begin
         Tempo.Interval := 1000;
         BtnConexao.Caption := 'Conectar';
      end;
   Tempo.Enabled := True;
end;

procedure TPrincipal.InjectDisconnectedBrute(Sender: TObject);
begin
   ShowMessage('Conexão foi finalizada pelo celular');
end;

procedure TPrincipal.InjectGetStatus(Sender: TObject);
begin
   if not Assigned(Sender) Then
      Exit;

   if (Inject.Status = Inject_Initialized) then
      WhatsappConectado := True
   else
      WhatsappConectado := False;

  LblStatus.Visible := False;
  case TInject(Sender).status of
    Server_ConnectedDown       : LblStatus.Caption := TInject(Sender).StatusToStr;
    Server_Disconnected        : LblStatus.Caption := TInject(Sender).StatusToStr;
    Server_Disconnecting       : LblStatus.Caption := TInject(Sender).StatusToStr;
    Server_Connected           : LblStatus.Caption := '';
    Server_Connecting          : LblStatus.Caption := TInject(Sender).StatusToStr;
    Inject_Initializing        : LblStatus.Caption := TInject(Sender).StatusToStr;
    Inject_Initialized         : LblStatus.Caption := TInject(Sender).StatusToStr;
    Server_ConnectingNoPhone   : LblStatus.Caption := TInject(Sender).StatusToStr;
    Server_ConnectingReaderCode: LblStatus.Caption := TInject(Sender).StatusToStr;
    Server_TimeOut             : LblStatus.Caption := TInject(Sender).StatusToStr;
    Inject_Destroying          : LblStatus.Caption := TInject(Sender).StatusToStr;
    Inject_Destroy             : LblStatus.Caption := TInject(Sender).StatusToStr;
  end;
  If LblStatus.Caption <> '' Then
     LblStatus.Visible := true;

   if (TInject(Sender).status <> Server_Disconnected) and (TInject(Sender).status <> Server_Connected) then
      begin
         BtnConexao.Enabled := False;
//         GroupBox1.Enabled := false;
         BtnConexao.Caption := 'Aguarde . . .';
      end
   else
      begin
         BtnConexao.Enabled := True;
//         GroupBox1.Enabled := true;
      end;


  LblStatus.Caption := LblStatus.Caption;

  If Inject.Status in [Server_ConnectingNoPhone, Server_TimeOut] Then
  Begin
    if Inject.FormQrCodeType = Ft_Desktop then
    Begin
       if Inject.Status = Server_ConnectingNoPhone then
          Inject.FormQrCodeStop;
    end else
    Begin
      if Inject.Status = Server_ConnectingNoPhone then
      Begin
        if not Inject.FormQrCodeShowing then
           Inject.FormQrCodeShowing := True;
      end else
      begin
        Inject.FormQrCodeReloader;
      end;
    end;
  end;
end;

procedure TPrincipal.InjectIsConnected(Sender: TObject; Connected: Boolean);
begin
   if Connected then
      WhatsappConectado := True
   else
      WhatsappConectado := False;
end;

procedure TPrincipal.TempoTimer(Sender: TObject);
begin
   IniciarEnvios;
end;

end.
