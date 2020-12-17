unit UBDados;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, Math, Variants, IniFiles,
  StdCtrls, ExtCtrls, DBCtrls, Grids, DBGrids, Mask, ComCtrls, Buttons,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.Phys.IBBase, FireDAC.Comp.UI;

  Function Nvl(wTexto:Variant;wResultado:Variant):Variant;

type
  TBDados = class(TDataModule)
    NovoCodigo: TFDQuery;
    Outros: TFDQuery;
    Pesquisa: TFDQuery;
    HoraBanco: TFDQuery;
    Parametro: TFDQuery;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    BDados: TFDConnection;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  wEmpresa      : Integer;
  Function fLerConteudo(wTabela:String;wCampoRef, wConteudoRef, wCampoRetorno:String):String; Overload;
  Function fLerConteudo(wTabela:String;wCampoRef, wConteudoRef, wCampoRetorno:String;wEmp:Integer):String; Overload;

  end;

var
  BDados: TBDados;
  wDescPesquisa : String;
  wCodigoPFJ    : String;
  wLiberarCompra: String;
  wDtDesativacao: String;
implementation

uses UFuncoes, UMenuPrincipal;

{$R *.DFM}

Function Nvl(wTexto:Variant;wResultado:Variant):Variant;
Begin
   If (wTexto = Null) or (wTexto = '') Then
      Result:= wResultado;
End;

procedure TBDados.DataModuleCreate(Sender: TObject);
var
   IniFile: TIniFile;
begin

   BDados.Connected := False;

   If FileExists(ExtractFilePath(Application.ExeName) + '\conexao.ini') Then
      Begin
         IniFile := TInifile.Create(ExtractFilePath(Application.ExeName) + '\conexao.ini');
         Try
            BDados.DriverName := 'FB';
            BDados.Params.DataBase := IniFile.ReadString('CONEXAO','DATABASE','');
            BDados.Params.UserName := IniFile.ReadString('CONEXAO','USER','SYSDBA');
            BDados.Params.PassWord := IniFile.ReadString('CONEXAO','PASSWORD','');
            //BDados.Connected := True;
         Except
            On E: Exception do
               Begin
                  MessageDlg('Conexão não efetuada'     + Chr(13) +
                  'Usuario.: ' + BDados.Params.UserName + Chr(13) +
                  'DataBase: ' + BDados.Params.Database + Chr(13) +
                  E.Message, mtError, [mbOK], 0);
                  Application.Terminate;
               End;
         End;
      End
   Else
      Begin
         MessageDlg('Arquivo conexao.ini não encontrado !!!',mtInformation,[mbOk],0);
         Application.Terminate;
      End;

   IniFile.Free;
end;

Function fFun_Par(wParametro:String):String;
Var
   wVlParametro : String;
Begin
   wVlParametro := '';

   With BDados Do
      Begin
         Parametro.ParamByName('wParametro').asString := UpperCase(wParametro);
         Parametro.Open;
         If Not Parametro.Eof Then
            wVlParametro := Parametro.FieldByName('VlParametro').asString;
         Parametro.Close;
      End;

   Result := wVlParametro;
End;

function TBDados.fLerConteudo(wTabela, wCampoRef, wConteudoRef,
  wCampoRetorno: String; wEmp: Integer): String;
Var
   FDBusca : TFDQuery;
Begin   //Função para conteúdo valor do campo da tabela
   FDBusca                   := Nil;
   FDBusca                   := TFDQuery.Create(FDBusca);
   FDBusca.Connection        := BDados;
   FDBusca.FetchOptions.Mode := fmAll;
   with FDBusca do
      begin
         close;
         sql.Clear;
         if BDados.DriverName = 'FB' then
            begin
               sql.Add('select first 1 '+wCampoRetorno+' from '+wTabela +
                       ' where ' + wCampoRef + ' = :wContCampo');
               if wEmp <> -1 then
                  SQL.Add(' and empresa = '+InttoStr(wEmp));
            end
         else
            begin
               sql.Add('select '+wCampoRetorno+' from '+wTabela +
                       ' where ' + wCampoRef + ' = :wContCampo');
               if wEmp <> -1 then
                  SQL.Add(' and empresa = '+InttoStr(wEmp));
               sql.Add(' and rownum = 1 ');
            end;

         parambyname('wContCampo').AsString := wConteudoRef;
         open;
         if not eof then
            Result := FieldByName(wCampoRetorno).AsString
         else
            Result := '';
      end;
   FDBusca.Destroy;
end;

function TBDados.fLerConteudo(wTabela, wCampoRef, wConteudoRef,
  wCampoRetorno: String): String;
begin
   result := fLerConteudo(wTabela,wCampoRef,wConteudoRef,wCampoRetorno,-1);
end;

end.



