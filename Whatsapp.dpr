program Whatsapp;

uses
  windows,
  Vcl.Forms,
  Vcl.Dialogs,
  uTInject.ConfigCEF,
  UMenuPrincipal in 'UMenuPrincipal.pas' {Form1},
  UBDados in 'UBDados.pas' {BDados: TDataModule};

{$E exe}

{$R *.res}

begin
  If not GlobalCEFApp.StartMainProcess then
     Exit;

   Application.Title := 'Envio Whatsapp';
   Application.Initialize;
   Application.MainFormOnTaskbar := True;
   Application.CreateForm(TPrincipal, Principal);
  Application.CreateForm(TBDados, BDados);
  Application.Run;
end.
