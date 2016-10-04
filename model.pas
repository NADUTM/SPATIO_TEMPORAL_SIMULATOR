unit model;

interface
uses
  classes, point3d, halfedge3d, MathTool, Math, eulerop, traverse, sysutils,Dialogs,Surface;

type
  HEdgeArray = array of THalfEdge3D;

  TModel = class
  protected
//ActiveQuad - quad used to navigate - current location in a model ke
//primalPointsList, dualPointsList - list of pointsin  a primal/dual graph
//shellsList - list of shells (worlds) - shell is set of lind cells (polihedra) not connected to other shell
//cellsList - list of cells (polihedra) - cell is closed polihedra (navigation possible with QE nav. op.)
//sells consists of cells
//tempFacePointsList - temporary structure used in construction process. Faces points are added one by one to this list.
//when a face is created the list is being cleared
    ActiveHEdge: THalfEdge3D;
    primalPointsList, dualPointsList, shellsList, {cellsList,}tempFacePointsList: TList;
    modelName: String;
    procedure Initialize; virtual;
    procedure Clear; virtual;
//    procedure showmessage(const Msg: String);
//    class var traverseId: Integer;
//    class procedure setTraverseIdForBunch(e: THalfEdge3D; currTrav: Integer);
//    class function getTraverseIdForBunch(e: THalfEdge3D): Integer;

  public
    class var
      OutsideVertex: TPoint3D;
      Surf:Tsurface;
      tempSurfaceList:TList;
    var
    cummTime: Double;
//    class function drawface(sur:Tsurface);
    class function getCellsList(shell: THalfEdge3D): TList;
    class function getFaceHEdges(he: THalfEdge3D): TList;
    class function ShellFaces(he: THalfEdge3D): TList;
    class function SearchEdgesInCell(e1, e2: THalfEdge3D; var resArr: HEdgeArray): Boolean; overload;
    class function SearchEdgesInCell(e: THalfEdge3D; pArr: array of TPoint3D; var resArr: array of THalfEdge3D): Boolean; overload;
    class function SearchEdgesInShell(e1, e2: THalfEdge3D; var resArr: HEdgeArray): Boolean; overload;
    class function SearchEdgesInShell(e: THalfEdge3D; pArr: array of TPoint3D; var resArr: array of THalfEdge3D): Boolean; overload;
    class function SearchEdgesIn(edges: TList; e2: THalfEdge3D; var resArr: HEdgeArray): Boolean; overload;
    class function SearchEdgesIn(edges: TList; pArr: array of TPoint3D; var resArr: array of THalfEdge3D): Boolean; overload;
//    class function isEdgeInShell(he, shell: THalfEdge3D): Boolean;
    class function FindEdgeInModel(shellsList: TList; id: Integer): THalfEdge3D;
    class function CalculateDualPointForPolyhedron(edges: TList): TPoint3D; overload;
    class function CalculateDualPointForPolyhedron(he: THalfEdge3D): TPoint3D; overload;
    class function CalculateDualPointForPolygon(pArr: array of TPoint3D): TPoint3D; overload;
    class function CalculateDualPointForPolygon(pList: TList): TPoint3D; overload;
    class function CalculateDualPointForFace(he: THalfEdge3D): TPoint3D;
    class procedure CalculateAndSetDualForCell(he: THalfEdge3D; inf: Boolean=False);
    class procedure SetDualForCell(he: THalfEdge3D; v: TPoint3D);
    class procedure SetDualForFace(he: THalfEdge3D; v: TPoint3D);
    class function isPointOutside(q: THalfEdge3D; p:TPoint3D): Boolean; overload;
    class function isPointOutside(edges: TList; p:TPoint3D): Boolean; overload;
    class function isOutsideDualPoint(v: TPoint3D): Boolean;
    class function getVwithINFtest(he: THalfEdge3D): TPoint3D;
    class function IsVertexInsideFace(var he: THalfEdge3D; v: TPoint3D): Integer;
    class function isPartOfFace(f, he: THalfEdge3D): Boolean;
    class function isPartOfFaceById(f: THalfEdge3D; id: Integer): Boolean;
    class function isPartOfCell(cell, he: THalfEdge3D): Boolean;
    class function NormalForFace(e: THalfEdge3D): TPoint3D;
    class function getOutsideDualPoint: TPoint3D;

    class function ConnectNeighbourFaces(f1, f2: THalfEdge3D): Boolean;

    constructor Create;
    destructor Destroy; override;
    function NewSurface(ID,SEM:Integer):TSurface; virtual;
    function NewPoint(x, y, z: Double): TPoint3D; virtual;
    procedure cleanPointLists;

    function getShellsList: TList; virtual;
    procedure setShellsList(shell: Pointer); virtual;
    function getEdgesList(cell: Pointer): TList; virtual;
    function getPrimalPointsList: TList; virtual;
    procedure setPrimalPointsList(ll: TList); virtual;
    function getDualPointsList: TList; virtual;
    procedure setDualPointsList(ll: TList); virtual;
    function getPrimalEdgesList: TList; virtual;
    function getDualEdgesList: TList; virtual;
    function getActiveHEdge: THalfEdge3D; virtual;
    procedure setActiveHEdge(q: THalfEdge3D);virtual;

    function KEF(he: THalfEdge3D): Boolean;
    function KEV(he: THalfEdge3D): Boolean;
    function KVE(he: THalfEdge3D): Boolean;
    function KZEV(he: THalfEdge3D): Boolean;
    function MEVVFS(x1, y1, z1, x2, y2, z2: Double): THalfEdge3D;
    function KEVVFS(he: THalfEdge3D): Boolean;
    function MEV(x1, y1, z1: Double; e: THalfEdge3D): THalfEdge3D;
    function MVE(x1, y1, z1: Double; e: THalfEdge3D): THalfEdge3D;
    function MZEV(e1, e2: THalfEdge3D): THalfEdge3D;
    function MEF(e1, e2: THalfEdge3D): THalfEdge3D;
    function JoinByFace(e1, e2: THalfEdge3D): THalfEdge3D;
    function DisjoinByFace(e1: THalfEdge3D): THalfEdge3D;
    function MergeByFace(e1, e2: THalfEdge3D): THalfEdge3D;
    function SplitByFace(eList: TList): THalfEdge3D;
    function JoinByEdge(e1, e2: THalfEdge3D): THalfEdge3D;
    function DisjoinByEdge(e1, e2: THalfEdge3D): THalfEdge3D;
    function MergeByEdge(e1, e2: THalfEdge3D): THalfEdge3D;
    function SplitByEdge(e1, e2: THalfEdge3D): THalfEdge3D;
    function JoinByVertex(e1, e2: THalfEdge3D): THalfEdge3D;
    function DisjoinByVertex(e1, e2: THalfEdge3D): THalfEdge3D;
    function MergeByVertex(e1, e2: THalfEdge3D): THalfEdge3D;
    function SplitByVertex(e1, e2: THalfEdge3D): THalfEdge3D;
    function MakeEdge(x1, y1, z1, x2, y2, z2: Double): THalfEdge3D;
    function KillEdge(he: THalfEdge3D): Boolean;
    function Splice(e1, e2: THalfEdge3D): THalfEdge3D;
    //

    function Extrude(z1:Double; f1: THalfEdge3D): THalfEdge3D;
    //Semantic Topological matched
//    function MakeFaceOnetoOne(f1,f2:ThalfEdge3D):THalfEdge3D;
//    Function MakeFaceTwotoOne(f1,f2:ThalfEdge3D): THalfEdge3D;
     function  EFFFMS(f1,f2:THalfEdge3D):THalfEdge3D;
      function CalculateEgeFromTwoFaces(f1,f2:ThalfEdge3D):THalfEdge3D;

     //
//     function Extrude2(z1:Double; f1: THalfEdge3D): THalfEdge3D;
    function CompareCells(var f1List, shList: TList; indxL, indxR: Integer; level: Integer): Boolean;
    procedure FindConnections;
    function DoMEF(e1, e2: THalfEdge3D; v1, v2: TPoint3D): THalfEdge3D;
    procedure addNewFaces(f: THalfEdge3D; var fList: TList; fListLastIndx: Integer; var e: THalfEdge3D);
    function findEdgeInFace(e: THalfEdge3D; v1, v2: TPoint3D): THalfEdge3D;
    function ConnectCells(f1Conn, f2Conn: THalfEdge3D; f1List, f2List: TList; var OutsideCellI: THalfEdge3D): Boolean;

    class procedure setNormForDirFace(e: THalfEdge3D; Q: Pointer);
    class function getNormForDirFace(e: THalfEdge3D): TPoint3D;
    class procedure delNormForDirFace(e: THalfEdge3D);

    procedure doTest;
    procedure doTest2;
    procedure doTest3;
    procedure navFaces(fList:TList; e:THalfEdge3D);
    function getBundleAttribStr(e:THalfEdge3D; name: String): String;
  end;

implementation
uses
  ST_Main;

constructor TModel.Create;
begin
primalPointsList:=TList.Create;
dualPointsList:=TList.Create;
shellsList:=TList.Create;
tempFacePointsList:=TList.Create;
tempSurfaceList:=TList.Create;
OutsideVertex:=nil;
Initialize;
end;

destructor TModel.Destroy;
begin
Clear;
primalPointsList.Free;
dualPointsList.Free;
shellsList.Free;
tempFacePointsList.Free;
if OutsideVertex<>nil then
  OutsideVertex.Free;
end;

procedure TModel.Initialize;
begin
ActiveHEdge:=nil;
TPoint3D.counter:=0;
THalfEdge3D.counter:=0;
THalfEdge3D.useDual:=True;//True,False
THalfEdge3D.useFaceLoops:=True;//True,False
end;

procedure TModel.Clear;
var
  i, j, k: Integer;
  he: THalfEdge3D;
  pointList: TList;
begin
if modelName='eul212121212' then
  begin
  pointList:=TList.Create;
  for i:=0 to shellsList.Count - 1 do
    begin
    for j:=0 to TList(shellsList.Items[i]).Count - 1 do
      begin
      with TGraphTraverse.getCellEdges(THalfEdge3D(TList(shellsList.Items[i]).Items[j])) do
        begin
        for k:=0 to Count-1 do
          begin
          he:=THalfEdge3D(Items[k]).Sym;
  //        if pointList.IndexOf(q.Org)=-1 then
  //          pointList.Add(q.Org);
          if THalfEdge3D.useDual and (pointList.IndexOf(he.Dual.GetV)=-1) then
            pointList.Add(he.Dual.GetV);
          THalfEdge3D.DestroyHEdge(he);
          he:=THalfEdge3D(Items[k]);
          if pointList.IndexOf(he.GetV)=-1 then
            pointList.Add(he.GetV);
          if THalfEdge3D.useDual and (pointList.IndexOf(he.Dual.GetV)=-1) then
            pointList.Add(he.Dual.GetV);
          THalfEdge3D.DestroyHEdge(he);
          end;
        Free;
        end;
      end;
    TList(shellsList.Items[i]).Free;
    end;
  shellsList.Clear;

  for i:=0 to pointList.Count-1 do
    TPoint3D(pointList.Items[i]).Free;
  pointList.Free;
  //for i:=0 to tempFacePointsList.Count - 1 do
  //  TPoint3D(tempFacePointsList.Items[i]).Free;
  //tempFacePointsList.Clear;
  end;
end;

function TModel.NewSurface(ID,SEM:Integer):TSurface;
var
Surfce:TSurface;
begin
 Surfce:=TSurface.Create(ID,SEM);
 tempsurfacelist.add(surfce);
 surfce.ListPrevID:=TStringlist.Create;
 surfce.ListnextID:=TStringlist.Create;
 Result:=Surfce;
end;



function TModel.NewPoint(x, y, z: Double): TPoint3D;
var
  i: Integer;
  temp: TPoint3D;
begin
temp:=nil;
for i:=0 to primalPointsList.Count-1 do
  if TPoint3D(primalPointsList.Items[i]).Equal(x, y, z, ddTol) then
    begin
    temp:=TPoint3D(primalPointsList.Items[i]);
    break;
    end;
if temp=nil then
  begin
  temp:=TPoint3D.Create(x, y, z, True);
  primalPointsList.Add(temp);
  end;
tempFacePointsList.Add(temp);
Result:=temp;
end;

class function TModel.getCellsList(shell: THalfEdge3D): TList;
var
  shellEdgesList, cellsList: TList;
begin
cellsList:=TList.Create;
shellEdgesList:=TGraphTraverse.getShellHalfEdges(shell);
while shellEdgesList.Count>0 do
  begin
  cellsList.Add(shellEdgesList.Items[0]);
  shellEdgesList.Assign(TGraphTraverse.getCellHEdges(shellEdgesList.Items[0]), laSrcUnique);
  end;
shellEdgesList.Free;
Result:=cellsList;
end;

class function TModel.getFaceHEdges(he: THalfEdge3D): TList;
var
  heList: TList;
  heTemp: THalfEdge3D;
begin
heList:=TList.Create;
heTemp:=he;
repeat
  heList.Add(heTemp);
  heTemp:=heTemp.NextF;
until heTemp=he;
Result:=heList;
end;

class function TModel.ShellFaces(he: THalfEdge3D): TList;
var
  heList, fList: TList;
  he1, heTemp: THalfEdge3D;
begin
fList:=TList.Create;
heList:=TGraphTraverse.getShellHalfEdges(he);
while heList.Count>0 do
  begin
  he1:=heList.First;
  heTemp:=he1.NextF;
  fList.Add(he1);
  heList.Delete(0);
  repeat
    heList.Remove(heTemp);
    heTemp:=heTemp.NextF;
  until he1=heTemp;
  end;

heList.Free;
Result:=fList;
end;

class function TModel.SearchEdgesInCell(e1, e2: THalfEdge3D; var resArr: HEdgeArray): Boolean;
begin
Result:=SearchEdgesIn(TGraphTraverse.getCellHEdges(e1), e2, resArr);
end;

class function TModel.SearchEdgesInCell(e: THalfEdge3D; pArr: array of TPoint3D; var resArr: array of THalfEdge3D): Boolean;
begin
Result:=SearchEdgesIn(TGraphTraverse.getCellHEdges(e), pArr, resArr);
end;

class function TModel.SearchEdgesInShell(e1, e2: THalfEdge3D; var resArr: HEdgeArray): Boolean;
begin
Result:=SearchEdgesIn(TGraphTraverse.getShellHalfEdges(e1), e2, resArr);
end;

class function TModel.SearchEdgesInShell(e: THalfEdge3D; pArr: array of TPoint3D; var resArr: array of THalfEdge3D): Boolean;
begin
Result:=SearchEdgesIn(TGraphTraverse.getShellHalfEdges(e), pArr, resArr);
end;

class function TModel.SearchEdgesIn(edges: TList; e2: THalfEdge3D; var resArr: HEdgeArray): Boolean;
var
  i: Integer;
  eTemp: THalfEdge3D;
  pList: TList;
  pArr: array of TPoint3D;
begin
pList:=TList.Create;
eTemp:=e2;
repeat
  pList.Add(eTemp.GetV);
  eTemp:=eTemp.Sym.NextV;//eTemp.NextV.Sym;//eTemp.Sym.NextV ???
until eTemp=e2;
setLength(pArr, pList.Count);
setLength(resArr, pList.Count);
for i:=0 to pList.Count-1 do
  begin
  pArr[i]:=pList.Items[i];
  resArr[i]:=nil;
  end;
pList.Free;

Result:=SearchEdgesIn(edges, pArr, resArr);
end;

class function TModel.SearchEdgesIn(edges: TList; pArr: array of TPoint3D; var resArr: array of THalfEdge3D): Boolean;
var
  i, j, hIndx: Integer;
  stop: Boolean;
  e, eTemp, resQ: THalfEdge3D;
begin
//Result = False - resArr(table of edges identical with a new face) is full. All edges found.
hIndx:=High(pArr);
Result:=False;

for j:=0 to hIndx do
  begin
  if resArr[j]<>nil then
    continue;
  Result:=True;
  stop:=False;
  for i:=0 to edges.Count-1 do
    begin
    e:=edges.Items[i];

    if (e.getV.Equal(pArr[j], ddTol)) and (e.Sym.GetV.Equal(pArr[(j+1) mod (hIndx+1)], ddTol)) then
      begin
      resQ:=e;
      if e.Adjacent.Sym<>e then
        begin
        eTemp:=e;
        repeat
//test if a new face is between two existing faces
          if TMathTool.AngleCoeff(eTemp.getV, eTemp.Sym.getV, eTemp.NextV.Sym.getV, pArr[(j+hIndx) mod (hIndx+1)])<= //index j+hIndx - previous from j
            TMathTool.AngleCoeff(eTemp.getV, eTemp.Sym.getV, eTemp.NextV.Sym.getV, eTemp.Sym.NextF.Sym.GetV) then
            begin
            if (edges.IndexOf(eTemp)>-1) or (edges.IndexOf(eTemp.Sym)>-1) then
              resQ:=eTemp
            else
              resQ:=nil;
            break;
            end;

          eTemp:=eTemp.Adjacent.Sym;//navigate from cell to cell around shared edge
        until eTemp=e;
        end;
      if resQ<>nil then
        begin
        resArr[j]:=resQ;
        stop:=True;
        break;
        end;
      end;

    if stop then
      break;
    end;
  end;
  edges.Free;
end;

class function TModel.FindEdgeInModel(shellsList: TList; id: Integer): THalfEdge3D;
var
  i, j: Integer;
  edgeList: TList;
begin
//find an edge with given id in Primal only
Result:=nil;
for i:=0 to shellsList.Count-1 do
  begin
  edgeList:=TGraphTraverse.getShellHalfEdges(shellsList.Items[i]);
  for j:=0 to edgeList.Count-1 do
    begin
    if THalfEdge3D(edgeList.Items[j]).getId=id then
      begin
      Result:=edgeList.Items[j];
      edgeList.Free;
      exit;
      end;
    end;
  edgeList.Free;
  end;
end;

class procedure TModel.CalculateAndSetDualForCell(he: THalfEdge3D; inf: Boolean=False);
var
  v: TPoint3D;
begin
if inf then
  v:=getOutsideDualPoint
else if he.getTypeFlag=2 then
  v:=CalculateDualPointForFace(he)
else
  v:=CalculateDualPointForPolyhedron(he);

if he.getTypeFlag=2 then
  SetDualForFace(he, v)
else
  SetDualForCell(he, v);
{
edges:=TModel.getCellEdges(he);
dNew:=CalculateDualPointForPolyhedron(edges);
//dOld:=THalfEdge3D(edges.Items[0]).Dual.getV;
for i:=0 to edges.Count-1 do
  begin
  THalfEdge3D(edges.Items[i]).Dual.SetV(dNew);
  THalfEdge3D(edges.Items[i]).Sym.Dual.SetV(dNew);

//  THalfEdge3D(edges.Items[i]).Dual.Sym.SetV(THalfEdge3D(edges.Items[i]).Dual.Sym.NextV.GetV);
//  THalfEdge3D(edges.Items[i]).Sym.Dual.Sym.SetV(THalfEdge3D(edges.Items[i]).Sym.Dual.Sym.NextV.GetV);
//  THalfEdge3D(edges.Items[i]).Dual.Sym.SetV(TPoint3D.Create(Infinity, Infinity, Infinity, True));
//  THalfEdge3D(edges.Items[i]).Sym.Dual.Sym.SetV(TPoint3D.Create(Infinity, Infinity, Infinity, True));
  end;
edges.Free;
}
end;

class procedure TModel.SetDualForCell(he: THalfEdge3D; v: TPoint3D);
var
  i: Integer;
  edges: TList;
  dOld, dNew: TPoint3D;
begin
edges:=TGraphTraverse.getCellEdges(he);
for i:=0 to edges.Count-1 do
  begin
  //THalfEdge3D(edges.Items[i]).Dual.SetV(v);
  //THalfEdge3D(edges.Items[i]).Sym.Dual.SetV(v);
  THalfEdge3D(edges.Items[i]).SetVD(v);
  THalfEdge3D(edges.Items[i]).Sym.SetVD(v)
  end;
edges.Free;
end;

class procedure TModel.SetDualForFace(he: THalfEdge3D; v: TPoint3D);
var
  heTemp: THalfEdge3D;
begin
heTemp:=he;
repeat
  heTemp.Sym.SetVD(v);
  heTemp:=heTemp.NextF;
until heTemp=he;
end;

class function TModel.CalculateDualPointForPolyhedron(edges: TList): TPoint3D;
var
  i, count: Integer;
  x, y, z: Double;
begin
count:=edges.Count;
x:=0.0; y:=0.0; z:=0.0;
for i:=0 to count-1 do
  begin
  x:=x+THalfEdge3D(edges.Items[i]).GetV.getX+THalfEdge3D(edges.Items[i]).Sym.GetV.getX;
  y:=y+THalfEdge3D(edges.Items[i]).GetV.getY+THalfEdge3D(edges.Items[i]).Sym.GetV.getY;
  z:=z+THalfEdge3D(edges.Items[i]).GetV.getZ+THalfEdge3D(edges.Items[i]).Sym.GetV.getZ;
  end;
Result:=TPoint3D.Create(x/count/2, y/count/2, z/count/2, True);
end;

class function TModel.CalculateDualPointForPolyhedron(he: THalfEdge3D): TPoint3D;
var
  edges: TList;
begin
edges:=TGraphTraverse.getCellEdges(he);
Result:=CalculateDualPointForPolyhedron(edges);
edges.Free;
end;

class function TModel.isOutsideDualPoint(v: TPoint3D): Boolean;
begin
if (v.getX=Infinity) and (v.getY=Infinity) and (v.getZ=Infinity) then
  Result:=True
else
  Result:=False;
end;

class function TModel.getVwithINFtest(he: THalfEdge3D): TPoint3D;
begin
if TModel.isOutsideDualPoint(he.GetV) then
  if he.GetTypeFlag=2 then
    Result:=TPoint3D.Create(he.Dual.GetV).Add(he.Dual.Sym.GetV).Divide(2.0)
  else
    Result:=TModel.CalculateDualPointForFace(he.Dual)
else
  Result:=he.GetV;
end;

class function TModel.getOutsideDualPoint: TPoint3D;
begin
if TModel.OutsideVertex=nil then
  TModel.OutsideVertex:=TPoint3D.Create(Infinity, Infinity, Infinity, True);
Result:=TModel.OutsideVertex;
end;

procedure TModel.cleanPointLists;
var
  i: Integer;
begin
i:=0;
while i<primalPointsList.Count do
  begin
  if TPoint3D(primalPointsList.Items[i]).getRef<=0 then
    begin
    TPoint3D(primalPointsList.Items[i]).Free;
    primalPointsList.Delete(i);
    end
  else
    Inc(i);
  end;

i:=0;
while i<dualPointsList.Count do
  begin
  if TPoint3D(dualPointsList.Items[i]).getRef<=0 then
    begin
    TPoint3D(dualPointsList.Items[i]).Free;
    dualPointsList.Delete(i);
    end
  else
    Inc(i);
  end;
end;

class function TModel.CalculateDualPointForFace(he: THalfEdge3D): TPoint3D;
var
  count: Integer;
  x, y, z: Double;
  qTemp: THalfEdge3D;
begin
count:=0;
x:=0.0; y:=0.0; z:=0.0;
qTemp:=he;
repeat
  x:=x+qTemp.GetV.getX;
  y:=y+qTemp.GetV.getY;
  z:=z+qTemp.GetV.getZ;
  Inc(count);
  qTemp:=qTemp.NextV.Sym;//NextF;
until qTemp=he;

Result:=TPoint3D.Create(x/count, y/count, z/count, True);
end;

class function TModel.CalculateDualPointForPolygon(pArr: array of TPoint3D): TPoint3D;
var
  i, count: Integer;
  x, y, z: Double;
begin
count:=High(pArr)+1;
x:=0.0; y:=0.0; z:=0.0;
for i:=0 to count-1 do
  begin
  x:=x+pArr[i].getX;
  y:=y+pArr[i].getY;
  z:=z+pArr[i].getZ;
  end;
Result:=TPoint3D.Create(x/count, y/count, z/count, True);
end;

class function TModel.CalculateDualPointForPolygon(pList: TList): TPoint3D;
var
  i: Integer;
  x, y, z: Double;
begin
x:=0.0; y:=0.0; z:=0.0;
for i:=0 to pList.Count-1 do
  begin
  x:=x+TPoint3D(pList.Items[i]).getX;
  y:=y+TPoint3D(pList.Items[i]).getY;
  z:=z+TPoint3D(pList.Items[i]).getZ;
  end;
Result:=TPoint3D.Create(x/pList.Count, y/pList.Count, z/pList.Count, True);
end;

class function TModel.isPointOutside(q: THalfEdge3D; p:TPoint3D): Boolean;
var
  edges: TList;
begin
edges:=TGraphTraverse.getCellEdges(q);
Result:=isPointOutside(edges, p);
edges.Free;
end;

class function TModel.isPointOutside(edges: TList; p:TPoint3D): Boolean;
var
  i: Integer;
  e: THalfEdge3D;
begin
Result:=False;
for i:=0 to edges.Count-1 do
  begin
  e:=edges.Items[i];
  if TMathTool.Det(e.getV, e.Sym.getV, e.Sym.NextV.Sym.GetV, p)>0 then
    begin
    Result:=True;
    break;
    end;
  e:=e.Sym;
  if TMathTool.Det(e.getV, e.Sym.getV, e.Sym.NextV.Sym.GetV, p)>0 then
    begin
    Result:=True;
    break;
    end;
  end;
end;

class function TModel.IsVertexInsideFace(var he: THalfEdge3D; v: TPoint3D): Integer;
var
  d0, d1, d2, anglesum, coef: Double;
  P1, P2, P3, vCross, vNorm: TPoint3D;
  e: THalfEdge3D;
begin
Result:=0;
anglesum:=0.0;
vNorm:=TModel.NormalForFace(he);
e:=he;
repeat
  P1:=TPoint3D.Create(e.GetV).Sub(v);
  P2:=TPoint3D.Create(e.Sym.GetV).Sub(v);
  d0:=TMathTool.Distance(e.getV, e.Sym.getV);
  d1:=P1.Distance;
  d2:=P2.Distance;

  if d1<=ddTol then
    begin
    he:=e;
    Result:=3;
    break;
    end
  else if d2<=ddTol then
    begin
    he:=e.NextF;
    Result:=3;
    break;
    end
{
  else if abs(d1+d2-d0)<=ddTol then
    begin
    he:=e;
    Result:=2;
    break;
    end
}
  else if vNorm<>nil then
    begin
    P3:=TPoint3D.Create(v);
    coef:=TMathTool.Det(e.getV, e.Sym.GetV, v, P3.Add(vNorm));
    if coef<-ddEPS then
      anglesum:=anglesum + ArcCos(TMathTool.Dot(P1, P2)/(d1*d2))
    else if coef>ddEPS then
      anglesum:=anglesum - ArcCos(TMathTool.Dot(P1, P2)/(d1*d2));
    //else if abs(coef)<ddEPS then ;
    P3.Free;
    end;
  P1.Free;
  P2.Free;
  e:=e.NextF;
until e=he;
//if vNorm<>nil then
//  vNorm.Free;
if (Result=0) then
  if (abs(abs(anglesum)-TMathTool.TWOPI)<=ddCalc) then
    Result:=1;
end;

class function TModel.isPartOfFace(f, he: THalfEdge3D): Boolean;
//test if edge (he) is in the face loop f
var
  eTemp: THalfEdge3D;
begin
Result:=False;
eTemp:=f;
repeat
  if eTemp=he then
    begin
    Result:=True;
    break;
    end;
  eTemp:=eTemp.NextF;
until eTemp=f;
end;

class function TModel.isPartOfFaceById(f: THalfEdge3D; id: Integer): Boolean;
//test if edge with ID is in the face loop f
var
  eTemp: THalfEdge3D;
begin
Result:=False;
eTemp:=f;
repeat
  if eTemp.getId=id then
    begin
    Result:=True;
    break;
    end;
  eTemp:=eTemp.NextF;
until eTemp=f;
end;

class function TModel.isPartOfCell(cell, he: THalfEdge3D): Boolean;
var
  eList: TList;
begin
Result:=False;
eList:=TGraphTraverse.getCellHEdges(cell);
if eList<>nil then
  begin
  if eList.indexOf(he)>=0 then
    Result:=True;
  eList.Free;
  end;
end;

class function TModel.NormalForFace(e: THalfEdge3D): TPoint3D;
var
  vList: TList;
//  Q, P1, P2, P3: TPoint3D;
  Q: TPoint3D;
  eTemp: THalfEdge3D;
begin
Q:=getNormForDirFace(e);
if Q<>nil then
  begin
  Result:=Q;
  exit;
  end;

vList:=TList.Create;
eTemp:=e;
repeat
  vList.Add(eTemp.GetV);
  eTemp:=eTemp.NextF;
until eTemp=e;
Q:=TMathTool.NormalForFace(vList);
vList.Free;

setNormForDirFace(e, Q);

Result:=Q;
{
Q:=nil;
eTemp:=e;
repeat
  P1:=eTemp.PrevF.GetV;
  P2:=eTemp.GetV;
  P3:=eTemp.Sym.GetV;
  //if not (P1.Equal(P2, dd)) and not (P1.Equal(P3, dd)) and not (P2.Equal(P3, dd)) then
  if abs(TMathTool.Distance(P1, P3)-TMathTool.Distance(P1, P2)-TMathTool.Distance(P2, P3))>ddTol then
    Q:=TMathTool.NNormalForTriangle(P1, P2, P3)
  else
    Q:=nil;
  eTemp:=eTemp.PrevF;
until ((eTemp=e) or (Q<>nil));
//if Q=nil then
//  Q:=TMathTool.NNormalForTriangle(P1, P2, P3);
Result:=Q;
}
end;

class procedure TModel.delNormForDirFace(e: THalfEdge3D);
var
  eTemp: THalfEdge3D;
begin
repeat
  eTemp:=TGraphTraverse.getAttribEdgeForDirectedFace(e, 'Norm');
  if eTemp<>nil then
    begin
    TPoint3D(eTemp.attrib.getAttribPtr('Norm')).Free;
    eTemp.attrib.delAttrib('Norm');
    end;
until eTemp=nil;

end;

class procedure TModel.setNormForDirFace(e: THalfEdge3D; Q: Pointer);
begin
delNormForDirFace(e);
if THalfEdge3D.useDual then
  e.Dual.attrib.setAttrib('Norm', Q)
else
  e.attrib.setAttrib('Norm', Q);
end;

class function TModel.getNormForDirFace(e: THalfEdge3D): TPoint3D;
var
  eTemp: THalfEdge3D;
begin
eTemp:=TGraphTraverse.getAttribEdgeForDirectedFace(e, 'Norm');
if eTemp<>nil then
  Result:=eTemp.attrib.getAttribPtr('Norm')
else
  Result:=nil;
end;

function TModel.getPrimalPointsList: TList;
var
  i: Integer;
  pointsList: TList;
begin
pointsList:=TList.Create;
for i:=0 to primalPointsList.Count-1 do
  if TPoint3D(primalPointsList.Items[i]).getRef>0 then
    pointsList.Add(primalPointsList.Items[i]);
Result:=pointsList;
end;

function TModel.getDualPointsList: TList;
var
  i: Integer;
  pointsList: TList;
begin
pointsList:=TList.Create;
for i:=0 to dualPointsList.Count-1 do
  if TPoint3D(dualPointsList.Items[i]).getRef>0 then
    pointsList.Add(dualPointsList.Items[i]);
Result:=pointsList;
end;

function TModel.getPrimalEdgesList: TList;
var
  i, j, k, l, cnt: Integer;
  addEdge: Boolean;
  eTemp1, eTemp2: THalfEdge3D;
  tempEdgesList, edgesList, cellsList: TList;
begin
edgesList:=TList.Create;
for i:=0 to shellsList.Count-1 do
  if ThalfEdge3D(shellsList.Items[i]).Dual.GetTypeFlag=2 then
    edgesList.Assign(TGraphTraverse.getCellEdges(ThalfEdge3D(shellsList.Items[i])),laOr)//QE
  else
    edgesList.Assign(TGraphTraverse.getShellBundles(ThalfEdge3D(shellsList.Items[i]).Adjacent.Sym),laOr);//3D
Result:=edgesList;
end;

function TModel.getDualEdgesList: TList;
var
  i, j, k, l: Integer;
  addEdge: Boolean;
  eTemp1, eTemp2: THalfEdge3D;
  tempEdgesList, edgesList, cellsList: TList;
begin
edgesList:=TList.Create;
for i:=0 to shellsList.Count-1 do
  edgesList.Assign(TGraphTraverse.getShellBundles(THalfEdge3D(shellsList.Items[i]).Dual),laOr);//3D
Result:=edgesList;
end;

function TModel.getActiveHEdge: THalfEdge3D;
begin
Result:=ActiveHEdge;
end;

procedure TModel.setActiveHEdge(q: THalfEdge3D);
begin
//if q<>nil then
  ActiveHEdge:=q;
end;

function TModel.getShellsList: TList;
begin
Result:=shellsList;
end;

procedure TModel.setShellsList(shell: Pointer);
begin
Self.shellsList:=shell;
end;

procedure TModel.setPrimalPointsList(ll: TList);
begin
Self.primalPointsList:=ll;
end;

procedure TModel.setDualPointsList(ll: TList);
begin
Self.dualPointsList:=ll;
end;

function TModel.getEdgesList(cell: Pointer): TList;
begin
Result:=TGraphTraverse.getCellEdges(cell);
end;

function TModel.KEF(he: THalfEdge3D): Boolean;
var
  indx: Integer;
  he1Exists, he2Exists: Boolean;
  heTemp, he1, he2: THalfEdge3D;
  cellHEdges, shellHEdges: TList;
begin
Result:=False;
if he.Adjacent.Sym.Adjacent.Sym<>he then
  exit;

heTemp:=he;
//test if no edges representing a shell will be removed
repeat
  indx:=shellsList.IndexOf(heTemp);
  if indx>=0 then
    begin
    shellsList.Items[indx]:=heTemp.NextV;
    break;
    end;
  indx:=shellsList.IndexOf(heTemp.Sym);
  if indx>=0 then
    begin
    shellsList.Items[indx]:=heTemp.Sym.NextV;
    break;
    end;
  heTemp:=heTemp.Adjacent.Sym;
until he=heTemp;

he1:=he.NextV;
he2:=he.Sym.NextV;

TEulerOp.KEF(he);

CalculateAndSetDualForCell(he1);
dualPointsList.Add(he1.Dual.getV);
cellHEdges:=TGraphTraverse.getCellHEdges(he1);
if cellHEdges.IndexOf(he2)<0 then
  begin
  CalculateAndSetDualForCell(he2);
  dualPointsList.Add(he2.Dual.getV);
  he1Exists:=False;
  he2Exists:=False;
  indx:=0;
  while indx<shellsList.Count do
    begin
    shellHEdges:=TGraphTraverse.getShellHalfEdges(shellsList.Items[indx]);
    if (not he1Exists) and (shellHEdges.IndexOf(he1)>=0) then
      he1Exists:=True;
    if (not he2Exists) and (shellHEdges.IndexOf(he2)>=0) then
      he2Exists:=True;
    shellHEdges.Free;
    if (he1Exists and he2Exists) then
      break;
    Inc(indx);
    end;
  if not he1Exists then
    shellsList.Add(he1);
  if not he2Exists then
    shellsList.Add(he2);
  end;


cellHEdges.Free;

indx:=0;
while indx<dualPointsList.Count do
  begin
  if TPoint3D(dualPointsList.Items[indx]).getRef<=0 then
    begin
    TPoint3D(dualPointsList.Items[indx]).Free;
    dualPointsList.Delete(indx);
    end
  else
    Inc(indx);
  end;


Result:=True;
end;

function TModel.KEV(he: THalfEdge3D): Boolean;
var
  indx: Integer;
  heTemp: THalfEdge3D;
begin
Result:=False;
//KEV is possible if only one end of the edge is free and  the second one is not
if (he.Adjacent.Sym.Adjacent.Sym<>he) then//we can remove one spare edge (not a bundle of edges)
  exit;
if ((he.NextV<>he) and (he.Sym.NextV<>he.Sym)) or
  ((he.NextV=he) and (he.Sym.NextV=he.Sym)) then
  exit;
if he.NextV=he then
  he:=he.Sym;

heTemp:=he;

//test if no edges representing a shell will be removed
repeat
  indx:=shellsList.IndexOf(heTemp);
  if indx>=0 then
    begin
    shellsList.Items[indx]:=heTemp.NextV;
    break;
    end;
  indx:=shellsList.IndexOf(heTemp.Sym);
  if indx>=0 then
    begin
    shellsList.Items[indx]:=heTemp.NextV;
    break;
    end;
  heTemp:=heTemp.Adjacent.Sym;
until he=heTemp;

TEulerOp.KEV(he);
Result:=True;
end;

function TModel.KVE(he: THalfEdge3D): Boolean;
var
  indx: Integer;
  heTemp: THalfEdge3D;
begin
heTemp:=he;
//test if run of KVE is possible
repeat
  if (heTemp.NextV=heTemp) or (heTemp.NextV.NextV<>heTemp) then
    begin
    Result:=False;
    exit;
    end;
  heTemp:=heTemp.Adjacent.Sym;
until he=heTemp;

//test if no edges representing a shell will be removed
repeat
  indx:=shellsList.IndexOf(heTemp);
  if indx>=0 then
    begin
    shellsList.Items[indx]:=heTemp.Sym;
    break;
    end;
  indx:=shellsList.IndexOf(heTemp.NextV);
  if indx>=0 then
    begin
    shellsList.Items[indx]:=heTemp.NextV.Sym;
    break;
    end;
  heTemp:=heTemp.Adjacent.Sym;
until he=heTemp;

TEulerOp.KVE(he);
Result:=True;
end;

function TModel.KZEV(he: THalfEdge3D): Boolean;
var
  indx: Integer;
  heTemp: THalfEdge3D;
begin
Result:=False;
//KEV2 is possible if two ends of the edge are connected to other edges
if (he.Adjacent.Sym.Adjacent.Sym<>he) or (he.Sym.Adjacent.Sym.Adjacent.Sym<>he.Sym) then//we can remove one spare edge (not a bundle of edges)
  exit;
if ((he.NextV=he) or (he.Sym.NextV=he.Sym)) then
  exit;

heTemp:=he;

//test if no edges representing a shell will be removed
repeat
  indx:=shellsList.IndexOf(heTemp);
  if indx>=0 then
    begin
    shellsList.Items[indx]:=heTemp.NextV;
    break;
    end;
  indx:=shellsList.IndexOf(heTemp.Sym);
  if indx>=0 then
    begin
    shellsList.Items[indx]:=heTemp.NextV;
    break;
    end;
  heTemp:=heTemp.Adjacent.Sym;
until he=heTemp;

TEulerOp.KZEV(he);
Result:=True;
end;

function TModel.MEVVFS(x1, y1, z1, x2, y2, z2: Double): THalfEdge3D;
var
  p1, p2, v: TPoint3D;
  e: THalfEdge3D;
begin
p1:=TPoint3D.Create(x1, y1, z1, True);
p2:=TPoint3D.Create(x2, y2, z2, True);
v:=TPoint3D.Create((x1+x2)/2, (y1+y2)/2, (z1+z2)/2, True);

primalPointsList.Add(p1);
primalPointsList.Add(p2);
dualPointsList.Add(v);

e:=TEulerOp.MEVVFS(p1, p2, v, getOutsideDualPoint);
shellsList.Add(e.Adjacent);
ActiveHEdge:=e;
Result:=e;
end;

function TModel.KEVVFS(he: THalfEdge3D): Boolean;
var
  indx: Integer;
  heTemp: THalfEdge3D;
begin
Result:=False;

heTemp:=he;
//test if run of KVVEFS is possible
repeat
  if (heTemp.NextV<>heTemp) or (heTemp.Sym.NextV<>heTemp.Sym) then
    exit;
  heTemp:=heTemp.Adjacent.Sym;
until he=heTemp;

//test if no edges representing a shell will be removed
repeat
  indx:=shellsList.IndexOf(heTemp);
  if indx>=0 then
    begin
    shellsList.Delete(indx);
    break;
    end;
  indx:=shellsList.IndexOf(heTemp.Sym);
  if indx>=0 then
    begin
    shellsList.Delete(indx);
    break;
    end;
  heTemp:=heTemp.Adjacent.Sym;
until he=heTemp;

TEulerOp.KEVVFS(he);
Result:=True;
end;

function TModel.MEV(x1, y1, z1: Double; e: THalfEdge3D): THalfEdge3D;
var
  p1: TPoint3D;
begin
p1:=TPoint3D.Create(x1, y1, z1, True);
primalPointsList.Add(p1);

e:=TEulerOp.MEV(p1, e);
ActiveHEdge:=e;
Result:=e;
end;

function TModel.MVE(x1, y1, z1: Double; e: THalfEdge3D): THalfEdge3D;
var
  p1: TPoint3D;
begin
p1:=TPoint3D.Create(x1, y1, z1, True);
primalPointsList.Add(p1);

e:=TEulerOp.MVE(p1, e);
ActiveHEdge:=e;
Result:=e;
end;

function TModel.MZEV(e1, e2: THalfEdge3D): THalfEdge3D;
var
  p1: TPoint3D;
begin
p1:=TPoint3D.Create(e1.getV, True);
primalPointsList.Add(p1);

e1:=TEulerOp.MZEV(p1, e1, e2);
ActiveHEdge:=e1;
Result:=e1;
end;

function TModel.MEF(e1, e2: THalfEdge3D): THalfEdge3D;
var
  i: Integer;
  e: THalfEdge3D;
  Surf:TSurface;
begin
if not TModel.isPartOfCell(e1.Adjacent, e2.Adjacent) then
  begin
  for i:=0 to shellsList.Count-1 do
    begin
    if TModel.isPartOfCell(shellsList.Items[i], e2.Adjacent)  then
      begin
      shellsList.Delete(i);
      break;
      end;
    end;
  end;

e:=TEulerOp.MEF(e1, e2);
//Surf:=TSurface.setHElist(e);
//self.SurHE:=TSurface.Create();
ActiveHEdge:=e;
Result:=e;
end;

function TModel.JoinByFace(e1, e2: THalfEdge3D): THalfEdge3D;
var
  i: Integer;
  e1OK, e2OK: Boolean;
  e1Temp, e2Temp, e3Temp: THalfEdge3D;
  eList: TList;
begin
if getFaceHEdges(e1).Count=getFaceHEdges(e2.Sym).Count then
  begin
//test if e1.Adjacent is not in shellsList - these faces (e1 and e2.Sym) will be removed
//test if e2.Sym.Adjacent is in different complex (than e1.Adjacent) and remove the complex from shellsList
  e1OK:=False;
  if TModel.isPartOfCell(e1.Adjacent, e2.Sym.Adjacent) then
    e2OK:=True
  else
    e2OK:=False;

  for i:=0 to shellsList.Count-1 do
    begin
    if (not e1OK) and TModel.isPartOfFace(shellsList.Items[i], e1.Adjacent) then
      begin
      shellsList.Items[i]:=THalfEdge3D(shellsList.Items[i]).Sym; //not always good
      e1OK:=True;
      end;
    if (not e2OK) and TModel.isPartOfCell(shellsList.Items[i], e2.Sym.Adjacent)  then
      begin
      shellsList.Items[i]:=nil;
      e2OK:=True;
      end;

    if e1OK and e2OK then
      break;
    end;
  shellsList.Pack;

  TEulerOp.ConnectCellsByFace(e1.Adjacent, e2.Adjacent);

  e1Temp:=e1;
  repeat
    eList:=TGraphTraverse.getEdgesAroundV(e1Temp);
    for i:=0 to eList.Count-1 do
      if e1Temp.getV <> THalfEdge3D(eList.Items[i]).getV then
        THalfEdge3D(eList.Items[i]).setV(e1Temp.getV);
    eList.Free;
    e1Temp:=e1Temp.NextF;
  until e1Temp=e1;

  Result:=e1
  end
else
  Result:=nil;
end;

function TModel.DisjoinByFace(e1: THalfEdge3D): THalfEdge3D;
var
  i: Integer;
  exists: Boolean;
  e2: THalfEdge3D;
  eList: TList;
begin
if e1.Adjacent.Sym.Adjacent.Sym<>e1 then
  begin
  e2:=e1.Adjacent.Sym;
  TEulerOp.DisconnectCellsByFace(e1);
  eList:=TGraphTraverse.getCellHEdges(e1.Adjacent);
  if eList.indexOf(e2)=-1 then
    begin
    exists:=False;
    for i:=0 to shellsList.Count-1 do
      if eList.IndexOf(shellsList.Items[i])>=0 then
        begin
        exists:=True;
        break;
        end;
    if exists then
      shellsList.Add(e2)
    else
      shellsList.Add(e1);
    end;

  eList.Free;
  Result:=e2;
  end
else
  Result:=nil;
end;

function TModel.MergeByFace(e1, e2: THalfEdge3D): THalfEdge3D;
var
  indx: Integer;
  heTemp: THalfEdge3D;
begin
//test if no edges representing a shell will be removed
e2:=e2.Sym;
heTemp:=e1;
repeat
  indx:=shellsList.IndexOf(heTemp);
  if indx>=0 then
    begin
    shellsList.Items[indx]:=heTemp.Sym;
    break;
    end;
  heTemp:=heTemp.NextF;
until e1=heTemp;

heTemp:=e2;
repeat
  indx:=shellsList.IndexOf(heTemp);
  if indx>=0 then
    begin
    shellsList.Items[indx]:=heTemp.Sym;
    break;
    end;
  heTemp:=heTemp.NextF;
until e2=heTemp;
//~test

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!//
heTemp:=e1.Sym;

//TEulerOp.ConnectCellsByFace(e1, e1.Adjacent.Sym, True);
TEulerOp.ConnectCellsByFace(e1, e2, True);

if not isOutsideDualPoint(heTemp.GetVD) then
  TModel.CalculateAndSetDualForCell(heTemp);
Result:=heTemp;
end;

function TModel.SplitByFace(eList: TList): THalfEdge3D;
{
var
  i: Integer;
  loopOK: Boolean;
  e1, e2: THalfEdge3D;
  pList: TList;
begin
//test if eList is a correct continious list of edges around a face (geometrically)
for i:=0 to eList.Count-1 do
  begin
  loopOK:=False;
  e1:=THalfEdge3D(eList.Items[i]).Sym;
  e2:=e1;
  repeat
    if e2=eList.Items[(eList.Count+i-1) mod eList.Count] then
      loopOK:=True
    else
      e2:=e2.NextV;
  until (loopOK or (e1=e2));

  if not loopOK then
    exit;
  end;

//prepare a face first - it will be the shared face between cells
pList:=TList.Create;
for i:=0 to eList.Count-1 do
  pList.Add(THalfEdge3D(eList.Items[i]).Sym.GetV);
e1:=TEulerOp.MakeFace(pList, THalfEdge3D(eList.Items[0]).GetVD).Sym;
pList.Free;
}
var
  e1, e2: THalfEdge3D;
begin
e1:=THalfEdge3D(eList.Items[0]);
e2:=THalfEdge3D(eList.Items[0]).Sym;

TEulerOp.SplitCellsByFace(eList);

TModel.CalculateAndSetDualForCell(e1);
TModel.CalculateAndSetDualForCell(e2);
Result:=e1.Sym;
end;

function TModel.JoinByEdge(e1, e2: THalfEdge3D): THalfEdge3D;
//input parameters are edges of internal cells - in fact, external edges are merged
var
  i: Integer;
  e2OK: Boolean;
  e1Temp, e2Temp, e3Temp: THalfEdge3D;
  eList: TList;
begin
//test if e2.Sym.Adjacent is in different complex (than e1.Adjacent) and remove the complex from shellsList
if not TModel.isPartOfCell(e1.Adjacent, e2.Adjacent) then   //e1 and e2 in same complex or not??
  begin
  for i:=0 to shellsList.Count-1 do     //list of one cell complex
    begin
    if TModel.isPartOfCell(shellsList.Items[i], e2.Adjacent)  then
      begin
      shellsList.Delete(i);
      break;      //break
      end;
    end;
  end;    //update the list of seperate cell complex

//TEulerOp.ConnectCellsByEdge(e1, e2);
TEulerOp.ConnectCellsByEdge(e1.Adjacent, e2.Adjacent);
e1Temp:=e1;
repeat
  eList:=TGraphTraverse.getEdgesAroundV(e1Temp);
  for i:=0 to eList.Count-1 do
    if e1Temp.getV <> THalfEdge3D(eList.Items[i]).getV then
      THalfEdge3D(eList.Items[i]).setV(e1Temp.getV);
  eList.Free;
  e1Temp:=e1Temp.Sym;
until e1Temp=e1;

Result:=e1
end;

function TModel.DisjoinByEdge(e1, e2: THalfEdge3D): THalfEdge3D;
var
  i: Integer;
  exists: Boolean;
  eList: TList;
begin
//if e1.Adjacent.Sym.Adjacent.Sym<>e1 then
  begin
//  e2:=e1.Adjacent.Sym;
  TEulerOp.DisconnectCellsByEdge(e1.Adjacent, e2.Adjacent);
  eList:=TGraphTraverse.getCellHEdges(e1.Adjacent);
  if eList.indexOf(e2)=-1 then
    begin
    exists:=False;
    for i:=0 to shellsList.Count-1 do
      if eList.IndexOf(shellsList.Items[i])>=0 then
        begin
        exists:=True;
        break;
        end;
    if exists then
      shellsList.Add(e2)
    else
      shellsList.Add(e1);
    end;

  eList.Free;
  Result:=e2;
  end
//else
//  Result:=nil;
end;

function TModel.MergeByEdge(e1, e2: THalfEdge3D): THalfEdge3D;
begin
TEulerOp.ConnectCellsByEdge(e1, e2);
//TModel.CalculateAndSetDualForCell(e1);
Result:=e1;
end;

function TModel.SplitByEdge(e1, e2: THalfEdge3D): THalfEdge3D;
begin
TEulerOp.ConnectCellsByEdge(e1, e2);
TModel.CalculateAndSetDualForCell(e1);
TModel.CalculateAndSetDualForCell(e2);
end;

function TModel.JoinByVertex(e1, e2: THalfEdge3D): THalfEdge3D;
var
  i: Integer;
  e2OK: Boolean;
  e1Temp, e2Temp, e3Temp: THalfEdge3D;
  eList: TList;
begin
//test if e2.Sym.Adjacent is in different complex (than e1.Adjacent) and remove the complex from shellsList
if not TModel.isPartOfCell(e1.Adjacent, e2.Adjacent) then
  begin
  for i:=0 to shellsList.Count-1 do
    begin
    if TModel.isPartOfCell(shellsList.Items[i], e2.Adjacent)  then
      begin
      shellsList.Delete(i);
      break;
      end;
    end;
  end;

TEulerOp.ConnectCellsByVertex(e1.Adjacent.Sym.PrevV, e2.Adjacent.Sym.PrevV);
e1Temp:=e1;
repeat
  eList:=TGraphTraverse.getEdgesAroundV(e1Temp);
  for i:=0 to eList.Count-1 do
    if e1Temp.getV <> THalfEdge3D(eList.Items[i]).getV then
      THalfEdge3D(eList.Items[i]).setV(e1Temp.getV);
  eList.Free;
  e1Temp:=e1Temp.Sym;
until e1Temp=e1;

Result:=e1
end;

function TModel.DisjoinByVertex(e1, e2: THalfEdge3D): THalfEdge3D;
var
  i: Integer;
  exists: Boolean;
  eList: TList;
begin
//if e1.Adjacent.Sym.Adjacent.Sym<>e1 then
  begin
//  e2:=e1.Adjacent.Sym;
  TEulerOp.ConnectCellsByVertex(e1.Adjacent.Sym.PrevV, e2.Adjacent.Sym.PrevV);
  eList:=TGraphTraverse.getCellHEdges(e1.Adjacent);
  if eList.indexOf(e2)=-1 then
    begin
    exists:=False;
    for i:=0 to shellsList.Count-1 do
      if eList.IndexOf(shellsList.Items[i])>=0 then
        begin
        exists:=True;
        break;
        end;
    if exists then
      shellsList.Add(e2)
    else
      shellsList.Add(e1);
    end;

  eList.Free;
  Result:=e2;
  end
//else
//  Result:=nil;
end;

function TModel.MergeByVertex(e1, e2: THalfEdge3D): THalfEdge3D;
begin
TEulerOp.ConnectCellsByVertex(e1, e2);
TModel.CalculateAndSetDualForCell(e1);
Result:=e1;
end;

function TModel.SplitByVertex(e1, e2: THalfEdge3D): THalfEdge3D;
begin
TEulerOp.ConnectCellsByVertex(e1, e2);
TModel.CalculateAndSetDualForCell(e1);
TModel.CalculateAndSetDualForCell(e2);
end;

function TModel.MakeEdge(x1, y1, z1, x2, y2, z2: Double): THalfEdge3D;
var
  p1, p2, v: TPoint3D;
  e: THalfEdge3D;
begin
p1:=NewPoint(x1, y1, z1);
p2:=NewPoint(x2, y2, z2);
v:=TPoint3D.Create((x1+x2)/2, (y1+y2)/2, (z1+z2)/2, True);
dualPointsList.Add(v);

e:=TEulerOp.MakeEdge(p1, p2, getOutsideDualPoint, 2);
shellsList.Add(e);
ActiveHEdge:=e;
Result:=e;
end;

function TModel.KillEdge(he: THalfEdge3D): Boolean;
var
  indx: Integer;
begin
Result:=False;
//test if KillEdge is possible
if (he.NextV<>he) or (he.Sym.NextV<>he.Sym) then
  exit;

//remove the shell from the shell list represented by removed edge
indx:=shellsList.IndexOf(he);
if indx>=0 then
  shellsList.Delete(indx)
else
  begin
  indx:=shellsList.IndexOf(he.Sym);
  if indx>=0 then
    shellsList.Delete(indx);
  end;

TEulerOp.KillEdge(he);
Result:=True;
end;

function TModel.Splice(e1, e2: THalfEdge3D): THalfEdge3D;
var
  i: Integer;
  e1Temp: THalfEdge3D;
  pTemp: TPoint3D;
begin
//test if e2.Sym.Adjacent is in different complex (than e1.Adjacent) and remove the complex from shellsList
if not TModel.isPartOfCell(e1, e2) then
  begin
  for i:=0 to shellsList.Count-1 do
    begin
    if TModel.isPartOfCell(shellsList.Items[i], e2)  then
      begin
      shellsList.Delete(i);
      break;
      end;
    end;
  end;

pTemp:=e1.GetV;
e1Temp:=e1;
repeat
  if e1Temp.getV <> e2.getV then
    e1Temp.setV(e2.getV);
  e1Temp:=e1Temp.NextV;
until e1Temp=e1;
if pTemp.getRef<=0 then
  begin
  primalPointsList.Remove(pTemp);
  pTemp.Free;
  end;

TEulerOp.Rop(e1, e2);

if not TModel.isPartOfCell(e1, e2) then
  begin
  for i:=0 to shellsList.Count-1 do
    begin
    if TModel.isPartOfCell(shellsList.Items[i], e2)  then
      begin
      shellsList.Add(e1);
      break;
      end;
    if TModel.isPartOfCell(shellsList.Items[i], e1)  then
      begin
      shellsList.Add(e2);
      break;
      end;
    end;
  end;

Result:=e1
end;
//*******************************************************************//
//**************************FindConnections**************************//
//*******************************************************************//

class function TModel.ConnectNeighbourFaces(f1, f2: THalfEdge3D): Boolean;
var
  he1, he2{, eTemp}: THalfEdge3D;
begin
he1:=f1;
he2:=f2;
repeat
  repeat
    if (he1.getV.Equal(he2.Sym.getV, ddTol)) and (he1.Sym.getV.Equal(he2.getV, ddTol)) {and (he1<>he2.Sym)} then
      begin
{      eTemp:=TGraphTraverse.getAttribEdgeForBunch(he1.Dual, 'Norm');
      if eTemp<>nil then
        eTemp.attrib.delAttrib('Norm');
      eTemp:=TGraphTraverse.getAttribEdgeForBunch(he2.Sym.Dual, 'Norm');
      if eTemp<>nil then
        eTemp.attrib.delAttrib('Norm');
}
      TEulerOp.ConnectCellsByFace(he1, he2.Sym);
      Result:=True;
      exit;
      end;
    he1:=he1.NextF;
  until (f1=he1);
  he2:=he2.NextF;
until (f2=he2);
Result:=False;
end;

function TModel.DoMEF(e1, e2: THalfEdge3D; v1, v2: TPoint3D): THalfEdge3D;
begin
Result:=nil;
case TMathTool.CompareVectorDirection(e1.GetV, e2.GetV, v1, v2) of
 1,0: Result:=TEulerOp.MEF(e2, e1);
-1: Result:=TEulerOp.MEF(e1, e2);
end;
end;

procedure TModel.addNewFaces(f: THalfEdge3D; var fList: TList; fListLastIndx: Integer; var e: THalfEdge3D);
var
  i: Integer;
  ePart, eSymPart: Boolean;
begin
ePart:=isPartOfFace(f, e);
eSymPart:=isPartOfFace(f, e.Sym);

if fListLastIndx<fList.Count then
  begin
  for i:=fListLastIndx to fList.Count-1 do
    begin
    if ePart and eSymPart then
      break;
    if (not ePart) and (isPartOfFace(fList.Items[i], e)) then
      ePart:=True;
    if (not eSymPart) and (isPartOfFace(fList.Items[i], e.Sym)) then
      eSymPart:=True;
    end;
  end;
if not ePart then
  fList.Add(e);
if not eSymPart then
  fList.Add(e.Sym);
end;

function TModel.Extrude (z1: Double; f1: THalfEdge3D): THalfEdge3D;//, Eo1v1z.text;
var
// ke : StrToFloat(EO1v1z.Text);
//  z1 : Double;
  i: Integer;
  nPoint: TPoint3D;
  eFirst, eNew, eTemp: THalfEdge3D;
begin
if f1=nil then
  begin
  Result:=nil;
  exit;
  end;

eFirst:=nil;
eTemp:=f1;
while eTemp<>eFirst do
  begin
  nPoint:=NewPoint(eTemp.GetV.getX, eTemp.GetV.getY, z1);
  eNew:=TEulerOp.MEV(nPoint, eTemp);
  if eFirst=nil then
    eFirst:=eNew;
  eTemp:=eTemp.NextF;
  end;
eTemp:=eFirst.NextF;
eFirst:=nil;
repeat
  eNew:=TEulerOp.MEF(eTemp, eTemp.NextF.NextF.NextF);
   if eFirst=nil then
    eFirst:=eNew;
    eTemp:=eNew.NextF;
until eTemp=eFirst;

ActiveHEdge:=eFirst;
Result:=eFirst;
end;

function TModel.EFFFMS(f1: THalfEdge3D; f2: THalfEdge3D):THalfEdge3D;
var
i,i1,i2:integer;
eTempFace1,eTempFace2,eFirst,efirstf1,efirstf2,eNew,enewf1,enewf2:THalfEdge3D;
pArr:array of TPoint3D;
v1:TPoint3D;
plist:TList;
begin


//eFirst:=nil;
eTempFace1:=f1;
eTempFace2:=f2;
plist:=TGraphTraverse.getCellFaces(eTempface1);
showmessage(inttostr(plist.Count));
eNew:=Nil; {
v1:=nil;
i:=8;
i2:=0;
etempface1:=f1;
efirstf1:=nil;
efirstf2:=f2;
enewf1:=etempface1;
enewf2:=etempface2;
//exit;
repeat
  enewf2:=eTempFace2.nextF;
  enewf1:=eTempFace1.nextF;
     i2:=i2+1;
      enew:=TEulerOp.MEF(etempface1,etempface2.NextV);
     etempface1:=etempface1.nextF;
     etempface2:=etempface2.NextF;

    until enewf2=efirstf2;

 shellslist.Add(enew);
 TMOdel.CalculateDualPointForPolyhedron(enew);  }

 { repeat
  enewf2:=eTempFace2.nextF;
     i2:=i2+1;
     etempface1:=etempface1.nextF;
     etempface2:=etempface2.NextF;

    until enewf2=efirstf2;
      showmessage (inttostr(i2));    }

//for i1 is bigger than i2 with
//i1/i2 =i3 which i3 is number of navigation through a face for different
//loop through 1st face
        {
etempface1:=f1;
etempface2:=f2;
//list of halfdge,

i:=0;
repeat
   enew:=TEulerop.MEF(etempface2,etempface1);
  etempface1:=etempface1.NextF;
  etempface2:=etempface2.NextF;
  i:=i+1;
until (i=i1);
  showmessage (inttostr(i));
  shellslist.add(enew);        }

  setActiveHEdge(eNew);
  shellsList.Add(eNew);
  //DrawModel(glscene);     }
  activeHedge:= etempface1;
Result:=enew;
end;


function TModel.CalculateEgeFromTwoFaces(f1: THalfEdge3D; f2: THalfEdge3D):THalfEdge3D;
 var
i1,i2:integer;
eTempFace1,eTempFace2,eFirst,efirstf1,efirstf2,eNew,enewf1,enewf2:THalfEdge3D;
pArr:array of TPoint3D;
v1:TPoint3D;
plist:TList;
begin

i1:=0;
efirstf1:=f1;
  repeat
  enewf1:=eTempFace1.nextF;
     i1:=i1+1;
     etempface1:=etempface1.NextF;
    until enewf1=efirstf1;
  showmessage (inttostr(i1));
  v1:=TModel.getOutsideDualPoint;

end;

{
function TModel.findEdgeInFace(e: THalfEdge3D; v1, v2: TPoint3D): THalfEdge3D;
var
  i: Integer;
  eTemp: THalfEdge3D;
begin
Result:=nil;
eTemp:=e;
repeat
  for i:=0 to 1 do
    begin
    eTemp:=eTemp.Sym;
    if (eTemp.getV.Equal(v1, dd)) and (eTemp.Sym.getV.Equal(v2, dd)) then
      begin
      if i=0 then
        eTemp:=eTemp.Sym;
      //e:=eTemp;
      Result:=eTemp;
      exit;
      end;
    end;

  eTemp:=eTemp.NextF;
until eTemp=e;
end;
}

function TModel.findEdgeInFace(e: THalfEdge3D; v1, v2: TPoint3D): THalfEdge3D;
var
  i: Integer;
  //u12: TPoint3D;
  eTemp: THalfEdge3D;
begin
Result:=nil;
eTemp:=e;
//u12:=TMathTool.CalculateUnitVector(v1, v2);
repeat
  for i:=0 to 1 do
    begin
    eTemp:=eTemp.Sym;
    //if (u12.Equal(TMathTool.CalculateUnitVector(eTemp.GetV, eTemp.Sym.GetV), dd)) then
    if (eTemp.getV.Equal(v1, ddTol)) and (eTemp.Sym.getV.Equal(v2, ddTol)) then
      begin
      if i=0 then
        eTemp:=eTemp.Sym;
      //e:=eTemp;
      Result:=eTemp;
      exit;
      end;
    end;

  eTemp:=eTemp.NextF;
until eTemp=e;
end;

function TModel.ConnectCells(f1Conn, f2Conn: THalfEdge3D; f1List, f2List:TList; var OutsideCellI: THalfEdge3D): Boolean;
var
  l, f1ToDel, f2ToDel, eCnt1, eCnt2: Integer;
  eTemp: THalfEdge3D;
  fList: TList;
begin
Result:=False;
if (f1Conn<>nil) and (f2Conn<>nil) then
  begin
  //test if adjacent faces to connect have the same number of edges
  eCnt1:=0;
  eCnt2:=0;
  eTemp:=f1Conn;
  repeat
    Inc(eCnt1);
    eTemp:=eTemp.NextF;
  until eTemp=f1Conn;
  eTemp:=f2Conn;
  repeat
    Inc(eCnt2);
    eTemp:=eTemp.NextF;
  until eTemp=f2Conn;
  if eCnt1<>eCnt2 then
    exit;
  //~test

  f1ToDel:=0;
  while f1ToDel<f1List.Count do
    begin
    if (f1List.Items[f1ToDel]<>nil) and ((f1Conn=f1List.Items[f1ToDel]) or (TModel.isPartOfFace(f1Conn, f1List.Items[f1ToDel]))) then
      break;
    Inc(f1ToDel);
    end;

  f2ToDel:=0;
  while f2ToDel<f2List.Count do
    begin
    if (f2List.Items[f2ToDel]<>nil) and ((f2Conn=f2List.Items[f2ToDel]) or (TModel.isPartOfFace(f2Conn, f2List.Items[f2ToDel]))) then
      break;
    Inc(f2ToDel);
    end;
{
  if (OutsideCellI<>nil) and (isPartOfFace(OutsideCellI, f1Conn)) then
    begin
    fList:=CellFaces(OutsideCellI);
    l:=1;
    while l<fList.Count do
      begin
      if (not isPartOfFace(f1Conn, fList.Items[l])) and ((not isPartOfFace(f2Conn, fList.Items[l]))) then
        begin
        OutsideCellI:=fList.Items[l];
        break;
        end;
      Inc(l);
      end;
    if l>=fList.Count then
      Form1.Memo1.Lines.Add('cell f1 is enclosed by f2 cell???');
    fList.Free;
    end;
}

  delNormForDirFace(f1Conn);
  delNormForDirFace(f2Conn);
  if ConnectNeighbourFaces(f1Conn{.Adjacent}, f2Conn{.Adjacent}) then
    begin
    if f1ToDel<f1List.Count then
      f1List.Items[f1ToDel]:=nil;
    if f2ToDel<f2List.Count then
      f2List.Items[f2ToDel]:=nil;
    Result:=True;
    end
  else
    Result:=False;
  end;
end;

function TModel.CompareCells(var f1List, shList: TList; indxL, indxR: Integer; level: Integer):Boolean;
var
  counter: Integer;
  nn: TPoint3D;
  nnTemp: THalfEdge3D;

  j, l, f1ListIndx, f2ListIndx, fListLastIndx, vCnt, holeCnt, edgeCnt, testRes, prevTestRes: Integer;
  Connected: Boolean;
  d2,dd: Double;
  f2List, fList: TList;
  n1, n2, nTemp, A, B, C, D, u, v, PTemp, PPTemp, vZero: TPoint3D;
  f1, f2, ff1, ff2, eTemp, e1Temp, e2Temp, preve1Temp, f1ToConnect, f2ToConnect : THalfEdge3D;

  startTime: TDateTime;
begin
counter:=0;

Result:=True;
n1:=nil;
n2:=nil;
vZero:=TPoint3D.Create(0.0, 0.0, 0.0);
j:=indxL+1;
while j<=indxR do
  begin
  if shList.Items[j]=nil then
    begin
    Inc(j);
    continue;
    end;
  Connected:=False;
  f2List:=TGraphTraverse.getCellFaces(shList.Items[j]);
  f2ListIndx:=0;
  while f2ListIndx<f2List.Count do
    begin
    if f2List.Items[f2ListIndx]=nil then
      begin
      Inc(f2ListIndx);
      continue;
      end;
    f2:=f2List.Items[f2ListIndx];
{    if n2<>nil then
      n2.Free;}
    n2:=NormalForFace(f2);
    f1ListIndx:=0;
    while f1ListIndx<f1List.Count do
      begin
      if f1List.Items[f1ListIndx]=nil then
        begin
        Inc(f1ListIndx);
        continue;
        end;
      f1:=f1List.Items[f1ListIndx];
//1. Test if faces are parallel and normal vectors are opposite (faces may be adjacent - so they have to have opposite loops)
      n1:=NormalForFace(f1);

      if n1<>nil then
        nTemp:=TPoint3D.Create(n1).Multi(-1.0);

      if (n1<>nil) and (n2<>nil) and (nTemp.Equal(n2, ddCalc*10)) and TMathTool.IsPointOnPlane(f2.getV, f1.GetV, n1) then //2. Test if faces are cooplanar - the faces are parallel, so it is enough to test if any vertex from f2 is on the same plane as f1
        begin
//3. Check all edges for intersections (face-face) - add new vertices on the edges

//inc(counter);
//if (counter=2215) and (indxL=0) and (indxR=632) then
//Form1.Memo1.Lines.Add(inttostr(counter)+' '+inttostr(indxL)+' '+inttostr(indxR));      //0, 632

        ff1:=f1;
        ff2:=f2;
        for l:=0 to 1 do
          begin
          e2Temp:=ff2;
          repeat
            e1Temp:=ff1;
            repeat
              A:=e1Temp.GetV;
              B:=e1Temp.Sym.GetV;
              C:=e2Temp.GetV;
              D:=e2Temp.Sym.GetV;

              eTemp:=nil;
              PTemp:=TMathTool.TwoSegmentsIntersection(A, B, C, D);
              if (PTemp<>nil) then //if there is the intersection point
                begin //check if it is not one of the ends of e2Temp edge
                if (not PTemp.Equal(C, ddTol)) and (not PTemp.Equal(D, ddTol)) then
                  begin
                  if PTemp.Equal(A, ddTol) then
                    PPTemp:=A
                  else if PTemp.Equal(B, ddTol) then
                    PPTemp:=B
                  else
                    PPTemp:=TPoint3D.Create(PTemp, true);
                  eTemp:=TEulerOp.MVE(PPTemp, e2Temp);//if not split eTemp2 edge
                  end;
                PTemp.Free;
                end
              else
                begin //add new nodes A and/or B do e2Temp if they are close enough to the edge
                v:=TPoint3D.Create(D).Sub(C);
                dd:=TMathTool.Distance(C, D);//¦CD¦
                //first check B
                //if B is on the e2Temp edge
                if (abs(TMathTool.Distance(C, B){¦CB¦}+TMathTool.Distance(B, D){¦BD¦}-dd)<=ddTol) and
                  (not B.Equal(C, ddTol)) and (not B.Equal(D, ddTol)) then // if B!=C and B!=D
                  begin
                  u:=TPoint3D.Create(B).Sub(C);
                  d2:=TMathTool.Dot(u, v)/v.Distance;   //d2 - distance between B and the edge (but only if it is between C and B
                  d2:=-d2*d2+u.Distance*u.Distance;     //cont.: this is only for precise calculations of distances
                  if abs(d2)<=ddTol*ddTol then
                    eTemp:=TEulerOp.MVE(B, e2Temp);//insert B to CD
                  u.Free;
                  end;
                if (abs(TMathTool.Distance(C, A){¦AB¦}+TMathTool.Distance(A, D){¦AD¦}-dd)<=ddTol) and
                  (not A.Equal(C, ddTol)) and (not A.Equal(D, ddTol)) then // if A!=C and A!=D
                  begin
                  u:=TPoint3D.Create(A).Sub(C);
                  d2:=TMathTool.Dot(u, v)/v.Distance;
                  d2:=-d2*d2+u.Distance*u.Distance;
                  if abs(d2)<=ddTol*ddTol then
                    begin
                    if (eTemp=nil) or (TMathTool.Distance(C, B)>TMathTool.Distance(C, A)){¦CB¦<¦CA¦} then
                      eTemp:=TEulerOp.MVE(A, e2Temp)//insert A to CD
                    else
                      {eTemp:=}TEulerOp.MVE(A, eTemp);
                    end;
                  u.Free;
                  end;
                v.Free;
                end;

                e1Temp:=e1Temp.NextF;
            until (e1Temp=ff1);
            e2Temp:=e2Temp.NextF;
          until ff2=e2Temp;
          ff1:=f2;
          ff2:=f1;
          end;

//4. go around f2 and test if there are shared parts with f1
//then f1<->f2 and do the same
        for l:=0 to 1 do
          begin
          if l=0 then
            begin
            ff1:=f1;
            ff2:=f2;
            fList:=f1List
            end
          else
            begin
            ff1:=f2;
            ff2:=f1;
            fList:=f2List;
            end;
          vCnt:=0;
          holeCnt:=0;
          edgeCnt:=0;
          preve1Temp:=ff1;
          prevTestRes:=IsVertexInsideFace(preve1Temp, ff2.NextV.Sym.getV);
          f1ToConnect:=nil;
          f1ToConnect:=nil;
          fListLastIndx:=fList.Count;
          e2Temp:=ff2;
          repeat
            e1Temp:=ff1;
//4. Check all edges for intersections (face-face) - add new vertices on the edge that is currently checked (e2Temp - from f2)

            testRes:=IsVertexInsideFace(e1Temp, e2Temp.getV);

            case (prevTestRes*10+testRes) of
            11:
              begin
              //e1Temp:=TEulerOp.MEVVFS(e2Temp.PrevF.GetV, e2Temp.GetV, ff1.Dual.getV, ff2.Dual.getV).Sym;
              e1Temp:=TEulerOp.MEVVFS(e2Temp.PrevF.GetV, e2Temp.GetV, ff1.Dual.getV, ff1.Dual.Sym.getV).Sym;
              testRes:=3;
              inc(vCnt);
              inc(holeCnt);
              end;
            13:
              begin
              e1Temp:=TEulerOp.MEV(e2Temp.PrevF.GetV, e1Temp).Sym;
              inc(vCnt);
              testRes:=3;
              end;
            31:
              begin
              e1Temp:=TEulerOp.MEV(e2Temp.GetV, preve1Temp).Sym;
              Inc(vCnt);
              if holeCnt>0 then
                Inc(holeCnt);
              testRes:=3;
              end;
            33:
              begin
              if (findEdgeInFace(e1Temp, e2Temp.getV, e2Temp.PrevF.getV)<>nil) then
                Inc(vCnt)
              else
                begin
                PTemp:=TPoint3D.Create(e2Temp.PrevF.getV).Add(e2Temp.getV).Divide(2.0);
                eTemp:=ff1;
                if TModel.IsVertexInsideFace(eTemp, PTemp)<>0 then
                  begin
                  e1Temp:=DoMEF(preve1Temp, e1Temp, e2Temp.PrevF.getV, e2Temp.getV);
                  addNewFaces(ff1, fList, fListLastIndx, e1Temp);
                  f1ToConnect:=e1Temp;
                  f2ToConnect:=e2Temp;
                  inc(vCnt);
{---}

                  eTemp:=TGraphTraverse.getAttribEdgeForDirectedBundle(e1Temp.Dual, 'Norm');
                  if eTemp<>nil then
                    e1Temp.Sym.Dual.attrib.setAttrib('Norm', TPoint3D.Create(TPoint3D(eTemp.attrib.getAttribPtr('Norm'))))
                  else
                    begin
                    eTemp:=TGraphTraverse.getAttribEdgeForDirectedBundle(e1Temp.Sym.Dual, 'Norm');
                    if eTemp<>nil then
                      e1Temp.Dual.attrib.setAttrib('Norm', TPoint3D.Create(TPoint3D(eTemp.attrib.getAttribPtr('Norm'))));
                    end;
{
                  eTemp:=TGraphTraverse.getAttribEdgeForDirectedFace(e1Temp, 'Norm');
                  if eTemp<>nil then
                    TGraphTraverse.setAttribForFace(e1Temp.Sym, 'Norm', TPoint3D.Create(TPoint3D(eTemp.attrib.getAttribPtr('Norm'))))
                  else
                    begin
                    eTemp:=TGraphTraverse.getAttribEdgeForDirectedFace(e1Temp.Sym, 'Norm');
                    if eTemp<>nil then
                      TGraphTraverse.setAttribForFace(e1Temp, 'Norm', TPoint3D.Create(TPoint3D(eTemp.attrib.getAttribPtr('Norm'))))
                    end;

                    }
{---}
                  end;
                PTemp.Free;
                end;
              end;
            end;

            Inc(edgeCnt);
            preve1Temp:=e1Temp;
            prevTestRes:=testRes;
            e2Temp:=e2Temp.NextF;
          until ff2=e2Temp;

          if holeCnt=edgeCnt then
            begin
            repeat
              eTemp:=e1Temp;
              e1Temp:=e1Temp.NextF;
              TEulerOp.KEV(eTemp);
            until e1Temp.NextF=e1Temp.Sym;
            TEulerOp.KEVVFS(e1Temp);
            e1Temp:=nil;
            break;
            end;
{
  //test if adjacent faces to connect have the same number of edges
if (f1ToConnect<>nil) and (f2ToConnect<>nil) then
begin
  vCnt:=0;
  edgeCnt:=0;
  eTemp:=f1ToConnect;
  repeat
    Inc(vCnt);
    eTemp:=eTemp.NextF;
  until eTemp=f1ToConnect;
  eTemp:=f2ToConnect;
  repeat
    Inc(edgeCnt);
    eTemp:=eTemp.NextF;
  until eTemp=f2ToConnect;
end;
}

          if (vCnt=edgeCnt) then
            begin
            if (f1ToConnect<>nil) and (f2ToConnect<>nil) then
              begin
              if l=1 then
                begin
                eTemp:=f2ToConnect;
                f2ToConnect:=f1ToConnect;
                f1ToConnect:=eTemp;
                end;
              end
            else
              begin
              f1ToConnect:=f1;
              f2ToConnect:=f2;
              end;

            eTemp:=shList.Items[indxL];
            if ConnectCells(f1ToConnect, f2ToConnect, f1List, f2List, eTemp) then
              begin
              Connected:=True;
              shList.Items[indxL]:=eTemp;
              end;

            f1ToConnect:=nil;
            f2ToConnect:=nil;

            if f2List.Items[f2ListIndx]=nil then
              begin
              f2:=nil;
              break;
              end;
            if f1List.Items[f1ListIndx]=nil then
              break;

            end;
          end;//for l:=0 to 1 do

        end;
      Inc(f1ListIndx);
      nTemp.Free;
      if f2=nil then
        break;
      end;//while f1ListIndx<f1List.Count do

      Inc(f2ListIndx);
    end;//while f2ListIndx<f2List.Count
  if Connected then
    begin
    shList.Items[j]:=nil;
    //if indxL<j-1 then
      Result:=CompareCells(f2List, shList, indxL, j-1, level+1);
    if not Result then
      exit;
    for l:=0 to f1List.Count-1 do
      if f1List.Items[l]<>nil then
        begin
        eTemp:=f1List.Items[l];
        break;
        end;
    //f1List.Free;
    //f1List:=TGraphTraverse.getCellFaces(eTemp);
    f1List.Assign(f2List, laOr);
    f2List.Clear;
    //j:=indxL;
    end;

  f2List.Free;
  Inc(j);
  end;
vZero.Free;
end;

procedure TModel.FindConnections;
var
  i, j: Integer;
  f1List: TList;
//
//  startTime: TDateTime;
begin
//cummTime:=0.0;
//startTime:=GetTime;
//shellsList.Items[0]:=THalfEdge3D(shellsList.Items[0]).Sym;
i:=0;
while i<shellsList.Count-1 do
  begin
  f1List:=TGraphTraverse.getCellFaces(shellsList.Items[i]);
  if not CompareCells(f1List, shellsList, i, shellsList.Count-1, 0) then
    begin
    shellsList.Pack;
    exit;
    end;
  for j:=0 to f1List.Count-1 do
    if (f1List.Items[j]<>nil) and (THalfEdge3D(f1List.Items[j]).Dual.getV=getOutsideDualPoint) then
      begin
      shellsList.Items[i]:=f1List.Items[j];
      break;
      end;

  f1List.Free;
  shellsList.Pack;
  Inc(i);
  end;
ActiveHEdge:=shellsList.Items[0];
//cummTime:=cummTime+GetTime-startTime;
//if cummTime>0.0 then
//;
end;

procedure TModel.doTest;
var
  i: Integer;
  coefL, coefR: Double;
  e, eTemp: THalfEdge3D;
  vList: TList;
begin
vList:=TList.Create;
e:=ActiveHEdge;
eTemp:=e;
repeat
  vList.Add(eTemp.GetV);
  eTemp:=eTemp.NextF;
until eTemp=e;

TMathTool.ConvexHull(vList);

e:=TEulerOp.MEVFFS(vList.Items[0], CalculateDualPointForPolygon(vList), CalculateDualPointForPolygon(vList));
shellsList.Add(e);
for i:=1 to vList.Count-1 do
  e:=TEulerOp.MVE(vList.Items[i], e);

vList.Free;
end;

procedure TModel.doTest2;
var
  i: Integer;
  coefL, coefR: Double;
  e, eTemp: THalfEdge3D;
  Q, P1, P2, P3: TPoint3D;
  vList: TList;
begin
vList:=TList.Create;
e:=ActiveHEdge;
eTemp:=e;
repeat
  vList.Add(eTemp.GetV);
  eTemp:=eTemp.NextF;
until eTemp=e;

Q:=TMathTool.NormalForFace(vList).Add(e.GetV);
e:=TEulerOp.MEVVFS(e.GetV, Q, CalculateDualPointForPolygon(vList), CalculateDualPointForPolygon(vList));
shellsList.Add(e);
vList.Free;
end;

function TModel.getBundleAttribStr(e:THalfEdge3D; name: String): String;
var
  eTempE: THalfEdge3D;
begin
eTempE:=e;
repeat
  if eTempE.attrib.indexOf(name)>-1 then
    begin
    Result:=eTempE.attrib.getAttribStr(name);
    exit;
    end;
  eTempE:=eTempE.Adjacent.Sym;
until eTempE=e;
Result:='';
end;

procedure TModel.navFaces(fList:TList; e:THalfEdge3D);
var
  eTempE, eTempV: THalfEdge3D;
begin
fList.Add(e);
e.attrib.setAttrib('visited', '1');
eTempE:=e;
repeat
  eTempV:=eTempE.NextV;
  while eTempV<>eTempE do
    begin
    if getBundleAttribStr(eTempV, 'visited')<>'1' then
      navFaces(fList, eTempV.Adjacent.Sym); //eTempV
    eTempV:=eTempV.NextV;
    end;
  eTempE:=eTempE.Adjacent.Sym;
until eTempE=e;

end;

procedure TModel.doTest3;
var
  fList: TList;
begin
fList:=TList.Create;
navFaces(fList, ActiveHEdge);
fList.Free;
end;

end.

