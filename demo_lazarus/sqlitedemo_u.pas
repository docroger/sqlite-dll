unit sqlitedemo_u;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, sqlite3conn, FileUtil, Forms, Controls, Graphics,
  Dialogs, StdCtrls, sqlite3dyn, db;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    SQLite3Connection1: TSQLite3Connection;
    SQLQuery1: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
     newfile:boolean;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }
function sqlite3_libversion:pchar;cdecl;external 'sqlite3.dll';

procedure TForm1.FormCreate(Sender: TObject);
begin
  SQLitedefaultLibrary := 'sqlite3.dll';
  sqlite3connection1.DatabaseName:=extractfilepath(application.exename)+'perso.db';
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
    SQLite3Connection1.Close; // Ensure the connection is closed when we start

  SQLite3Connection1.Password :=''; // txtPass.Text;

  try
    newFile := not FileExists(SQLite3Connection1.DatabaseName);
    if newFile then
    begin
      try
        SQLite3Connection1.Open;
        SQLTransaction1.Active := true;
        //SQLite3Connection1.ExecuteDirect('PRAGMA user_version = ' + IntToStr(user_version) + ';');
        //SQLite3Connection1.ExecuteDirect('PRAGMA application_id = ' + IntToStr(application_id) + ';');
        SQLite3Connection1.ExecuteDirect('CREATE TABLE "DATA"('+
                    ' "id" Integer NOT NULL PRIMARY KEY AUTOINCREMENT,'+
                    '"prenom" TEXT,'+
                    '"nom" TEXT);');
                    //' "Current_Time" DateTime NOT NULL,'+
                    //' "User_Name" Char(128) NOT NULL,'+
                    //' "Info" Char(128) NOT NULL);');


        // Creating an index based upon id in the DATA Table
        //SQLite3Connection1.ExecuteDirect('CREATE UNIQUE INDEX "Data_id_idx" ON "DATA"( "id" );');


        SQLTransaction1.Commit;
        ShowMessage('Succesfully created database.');
      except
        ShowMessage('Unable to Create new Database');
      end;
    end;
  except
    ShowMessage('Unable to check if database file exists');
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  s:string;
begin
   try
      if not(sqlite3connection1.Connected) then
        sqlite3connection1.Open;
     //
     if sqlite3connection1.Connected=false then
      begin
        ShowMessage('Error connecting to the database. Aborting data loading.');
        exit;
      end;
      sqlquery1.SQL.Text:='select * from DATA';

      sqltransaction1.StartTransaction;
      sqlquery1.Open;
      s:='';
      memo1.Text:='';
      while not(sqlQuery1.EOF) do
          begin
            s:=s+sqlquery1.Fields[0].AsString+#13;
            s:=s+sqlQuery1.Fields[1].AsString+#13;
            s:=s+sqlQuery1.Fields[2].AsString+#13;
            //Count:=Count+1;
            sqlQuery1.Next;
          end;

      memo1.Text:=s;
      sqlquery1.Close;
      sqltransaction1.Commit;
    except
      on D: EDatabaseError do
      begin
        MessageDlg('Error', 'A database error has occurred. Technical error message: ' +
          D.Message, mtError, [mbOK], 0);
      end;
    end;
 //
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  //SQLite3Connection1.Password := txtPass.Text; // The current password

    try
      SQLite3Connection1.Open;
      SQLTransaction1.Active := True;

      SQLQuery1.SQL.Text := 'Insert into DATA (prenom,nom) values (:prenom,:nom)';
      //SQLQuery1.Params.ParamByName('prenom').AsDateTime := Now;
      SQLQuery1.Params.ParamByName('prenom').AsString := edit1.Text;
      SQLQuery1.Params.ParamByName('nom').AsString := edit2.Text;
      SQLQuery1.ExecSQL;
      SQLTransaction1.Commit;
      // Clear Edit boxes
      edit1.Text := '';
      edit2.Text := '';
    except
      ShowMessage('Unable to add User_Name: ' + edit1.Text + ' and Info: ' + edit2.Text + ' to the database. Ensure database exists and password is correct.');
    end;

end;

procedure TForm1.Button4Click(Sender: TObject);
begin
   sqlQuery1.SQL.Text:='update DATA set prenom=:prenom, nom=:nom '+
        ' where id=1';
      sqlQuery1.Params.ParamByName('prenom').AsString:=edit1.text;
      sqlQuery1.Params.ParamByName('nom').AsString:=edit2.text;
      sqlTransaction1.StartTransaction;
      sqlQuery1.ExecSQL;
      sqltransaction1.Commit;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  //SQLite3Connection1.Connected := True;

    // Set SQL text to count all rows from the DATA table
    SQLQuery1.SQL.Clear;
    SQLQuery1.SQL.Text := 'Select Count(*) from DATA';
    SQLQuery1.Open;
    label1.caption:=sqlquery1.fields[0].AsString;
    sqlquery1.Close;
    sqltransaction1.Commit;
end;

procedure TForm1.Button6Click(Sender: TObject);
var
  s:string;
begin
  s:=sqlite3_libversion;
  label2.caption:=s;
end;

end.

