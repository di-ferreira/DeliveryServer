unit Server.Delivery.Model.Interfaces;

interface

uses
  System.Generics.Collections, FireDAC.Comp.Client, System.JSON;

type
  iModelServerDelivery<T: class, constructor> = interface
    ['{0935BD54-9FC4-48DE-AB7D-FB14E60B8391}']
    function Save(aValue: T): TJSONObject;
    function GetAll: TJSONArray;
    function GetByID(aID: Integer): TJSONObject;
    function Update(aValue: T): TJSONObject;
    function Delete(aID: Integer): TJSONObject; overload;
  end;

  iModelServerDeliveryCliente<T: class, constructor> = interface(iModelServerDelivery<T>)
    ['{9DE54436-2BF6-4211-BF11-DFEB8D96F529}']
    function GetByContato(aContato: string): TJSONObject;
    function Delete(aValue: string): TJSONObject; overload;
  end;

  iModelServerDeliveryEndereco<T: class, constructor> = interface(iModelServerDelivery<T>)
    ['{445CC15B-AD35-4CC1-B2FE-771A1F28256B}']
    function GetAll(aID_CLIENTE: Integer): TJSONArray; overload;
  end;

  iModelServerDeliveryCardapio<T: class, constructor> = interface(iModelServerDelivery<T>)
    ['{1834A103-1A77-450A-BFD6-89981EB9CB0D}']
    function GetByTipo(aID_TIPO: Integer): TJSONArray;
  end;

  iModelServerDeliveryCaixa<T: class, constructor> = interface(iModelServerDelivery<T>)
    ['{4743CC70-21D4-4BA8-8D5B-07B22CBBDF2D}']
    function GetByDate(aDate: TDate): TJSONObject;
    function GetBetweenDates(aInitalDate, aFinalDate: TDate): TJSONArray;
  end;

  iModelServerDeliveryConnection = interface
    ['{538D49B4-4CDE-424C-8C5E-E520F01DC628}']
    function Connection: TFDConnection;
    procedure AfterConnection(Sender: TObject);
  end;

implementation

end.

