unit eulerop;

interface

uses
  classes, obj3D, point3d, halfedge3d, math, traverse;

type
  TEulerOp = class
  private
    class function MakeHEdge(p, d: TPoint3D; f:Integer=0): THalfEdge3D;//Level 0
    class procedure KillHEdge(he: THalfEdge3D);//Level 0
//    class procedure SpliceHAQEs(q1, q2:TQuad3D);//Level 0
    class procedure ConnectHEdges(he1, he2: THalfEdge3D);//Level 1  ->0
    class procedure DisconnectHEdges(he1: THalfEdge3D);//Level 1    ->0

    class procedure SnapFaces(he1, he2Sym: THalfEdge3D);//Level 3 ??

    class function MakeComplexEdge(p1, p2, pIn, pOut: TPoint3D): THalfEdge3D;//Level 3
    class function KillComplexEdge(eIn: THalfEdge3D): THalfEdge3D;//Level 3
  public
  class var
    fCnt, eCnt: Integer;//face and edge counters
  var
    class procedure ComplexSplice(he1In, he2In: THalfEdge3D);//Level 0

    class function MakeEdge(p1, p2, d: TPoint3D; f:Integer=0): THalfEdge3D;//Level 2
    class procedure KillEdge(e: THalfEdge3D); //Level 2

    class function MakeDegenerateEdge(p, d: TPoint3D; f:Integer=0): THalfEdge3D;//Level 2
    class procedure KillDegenerateEdge(e: THalfEdge3D); //Level 2

    class procedure QPop(e1, e2: THalfEdge3D);
    class procedure QDop(e1, e2: THalfEdge3D);
    class procedure Rop(e1, e2: THalfEdge3D);
    class procedure Sop(e1, e2: THalfEdge3D);

    class function MakeFace(pList: TList; v: TPoint3D):THalfEdge3D; overload;//Level 3
    class function MakeFace(pArr: array of TPoint3D; v: TPoint3D):THalfEdge3D; overload;//Level 3
    class procedure KillFace(he: THalfEdge3D);//Level 3

    class function MEVVFS(p1, p2, pIn, pOut: TPoint3D):THalfEdge3D;
    class procedure KEVVFS(e: THalfEdge3D);
    class function MEVFFS(p, pIn, pOut: TPoint3D):THalfEdge3D;
    class procedure KEVFFS(he: THalfEdge3D);
    class function MEV(p: TPoint3D; he: THalfEdge3D):THalfEdge3D;
    class procedure KEV(he: THalfEdge3D);
    class function MVE(p: TPoint3D; he: THalfEdge3D): THalfEdge3D;
    class procedure KVE(he: THalfEdge3D);
    class function MZEV(p: TPoint3D; he1, he2: THalfEdge3D):THalfEdge3D;
    class procedure KZEV(he: THalfEdge3D);
    class function MEF(he1, he2: THalfEdge3D): THalfEdge3D;
    class procedure KEF(he: THalfEdge3D);
    class function KEMFS(he: THalfEdge3D): THalfEdge3D;
    class function MEKFS(he1, he2: THalfEdge3D): THalfEdge3D;

    class procedure ConnectCellsByFace(he1, he2: THalfEdge3D; _killFace: Boolean=True);
    class procedure DisconnectCellsByFace(he1: THalfEdge3D);//MGS???
    class procedure MergeCellsByFaceEO(he1, he2: THalfEdge3D);
    class procedure SplitCellsByFace(he1, he2: THalfEdge3D);overload;
    class procedure SplitCellsByFace(eList: TList);overload;

    class procedure ConnectCellsByEdge(he1, he2: THalfEdge3D);//KGS2???
    class procedure DisconnectCellsByEdge(he1, he2: THalfEdge3D);//MGS2???
    class procedure MergeCellsByEdge(he1, he2: THalfEdge3D);//KGS2???
    class procedure SplitCellsByEdge(he1, he2: THalfEdge3D);//MGS2???

    class procedure ConnectCellsByVertex(he1, he2: THalfEdge3D);//KGS3???
    class procedure DisconnectCellsByVertex(he1, he2: THalfEdge3D);//MGS3???
    class procedure MergeCellsByVertex(he1, he2: THalfEdge3D);
    class procedure MergeCellsByVertexEO(he1, he2: THalfEdge3D);
    class procedure SplitCellsByVertex(he1, he2: THalfEdge3D);
    class procedure SplitCellsByVertexEO(he1, he2: THalfEdge3D);

  end;

implementation

uses
  model;

(********************************Euler operators II********************************)
class function TEulerOp.MEVVFS(p1, p2, pIn, pOut: TPoint3D):THalfEdge3D;
//Make Edge Two Vertices Face and Shell = MakeEdge
//this operator is used to create an edge in empty space
//p1, p2 - vertices
//pIn, pOut - dual points
begin
Result:=MakeComplexEdge(p1, p2, pIn, pOut);
end;

class procedure TEulerOp.KEVVFS(e: THalfEdge3D);
//Kill Edge Two Vertices Faces Shell - reverse operator to MEVVFS
begin
//small test (not included in the final ver.):
if (e.NextV<>e) or (e.Sym.NextV<>e.Sym) then//if one of the ends of the edge is connected to any other edge then exit
  exit;
//~test
KillComplexEdge(e);
end;

class function TEulerOp.MEVFFS(p, pIn, pOut: TPoint3D):THalfEdge3D;
//Make Edge Vertex Two Faces and Shell = MakeEdge with one shared vertex
//this operator is used to create an edge in empty space
//p1 - vertices
//pIn, pOut - dual points
var
  he: THalfEdge3D;
begin
he:=MakeComplexEdge(p, p, pIn, pOut);
TEulerOp.ComplexSplice(he, he.Sym);
Result:=he;
end;

class procedure TEulerOp.KEVFFS(he: THalfEdge3D);
//Kill Edge Vertex Two Faces Shell - reverse operator to MEVFFS
begin
//small test (not included in the final ver.):
if (he.NextV<>he.Sym) or (he.Sym.NextV<>he) then//if one of the ends of the edge are not connected together then exit
  exit;
//~test

KillComplexEdge(he);
end;

class function TEulerOp.MEV(p: TPoint3D; he: THalfEdge3D):THalfEdge3D;
//Make Edge Vertex - add an edge to a cell - one end of the edge is free
var
  heN: THalfEdge3D;
begin
heN:=MakeComplexEdge(he.GetV, p, he.GetVD, he.Adjacent.GetVD);
TEulerOp.ComplexSplice(heN, he);
Result:=heN;
end;

class procedure TEulerOp.KEV(he: THalfEdge3D);
begin
//small test(not included in final ver.)::
if (he.NextV<>he) and (he.Sym.NextV<>he.Sym) then//if both ends of the edge are connected to the rest of the structure then exit
  exit;
if he.NextV=he then//if this end of the edge is not connected to the rest of the structure take the second end
  he:=he.Sym;
//~test

TEulerOp.ComplexSplice(he, he.Sym.NextF);//disconnect edge from the rest of the structure
KillComplexEdge(he);
end;

class function TEulerOp.MVE(p: TPoint3D; he: THalfEdge3D): THalfEdge3D;
//Make Vertex Edge - add a vertex on an existing edge = divide the edge into two
//vertices have to be added in all cells around the q edge
var
  i, eId: Integer;
  cellList, newEdgesList: TList;
  originEdge, newEdge, newEdgeNext: THalfEdge3D;
begin
cellList:=TList.Create;
newEdgesList:=TList.Create;
originEdge:=he;
//create a list of cells around the input edge - this is a list of edges withe the same vertices
//for each edge around the input edge create new edge e.Org=p and e.Dest=p
repeat
  cellList.Add(originEdge);
  newEdgesList.Add(MakeDegenerateEdge(p, originEdge.GetVD, originEdge.GetTypeFlag)); //for each edge around the input edge create new edge e.Org=p and e.Dest=p
  originEdge:=originEdge.NextE;//Adjacent.Sym;
until originEdge=he;

//connect new edges with existing structure
for i:=0 to cellList.Count-1 do
  begin
  originEdge:=cellList.Items[i];
  newEdge:=newEdgesList.Items[i];
  newEdgeNext:=newEdgesList.Items[(i+1) mod newEdgesList.Count]; //adjacent edge from the next cell
  TEulerOp.QPop(newEdge, originEdge);
  TEulerOp.QDop(newEdge, newEdgeNext.NextV);
  end;

cellList.Free;
newEdgesList.Free;
Result:=he.Sym.NextV;
end;

class procedure TEulerOp.KVE(he: THalfEdge3D);
var
  i: Integer;
  heTemp, e1, e2, e1Sym, e2Sym, eTemp: THalfEdge3D;
  cellList: TList;
begin
//small test(not included in final ver.)::
if (he.NextV=he) or (he.NextV.NextV<>he) then//if he is connected to zero or more than 1 edge then exit
  exit;
//~test

cellList:=TList.Create;
heTemp:=he;
repeat
  cellList.Add(heTemp);

//connect opposite ends of edges with the same shared point he.V and connect the rest of halves toghether
//  TEulerOp.ConnectHEdges(heTemp.NextV.Sym, heTemp.Sym);
//  TEulerOp.ConnectHEdges(heTemp.NextV, heTemp);
  //TEulerOp.QPop(heTemp.NextV.Sym, heTemp);

  heTemp:=heTemp.Adjacent.Sym;
until heTemp=he;

for i:=0 to cellList.Count-1 do
  begin
  heTemp:=cellList.Items[i];
//  e1:=heTemp;
//  e2:=heTemp.NextV.Sym;
  TEulerOp.QPop(heTemp.NextV.Sym, heTemp);
{  if THalfEdge3D.useFaceLoops then
    begin
    e1Sym:=e1.Sym;
    e2Sym:=e2.Sym;

    eTemp:=e1Sym.NextF;
    e1Sym.SetNextF(e2Sym.NextF);
    e2Sym.SetNextF(eTemp);

    eTemp:=e1.NextF;
    e1.SetNextF(e2.NextF);
    e2.SetNextF(eTemp);
    end;
}
  KillDegenerateEdge(heTemp);
  end;
cellList.Free;
end;

class function TEulerOp.MZEV(p: TPoint3D; he1, he2: THalfEdge3D):THalfEdge3D;
//Make Edge Vertex - Split a Vertex
//p - new point
// he1, he2 - edges in a bunch to disconnect - insert a new edge between he1 and he2
//this operator works for single cell - not in cell complex

//MZEV - Make Zero length Edge and Vertex (according to Lee)
//in our operator we change geometry as well, but we don't have to
var
  eTemp: THalfEdge3D;
begin

TEulerOp.ComplexSplice(he1, he2);
eTemp:=he2;
repeat
  eTemp.SetV(p);
  eTemp.Adjacent.Sym.SetV(p);
  eTemp:=eTemp.NextV;
until eTemp=he2;

Result:=TEulerOp.MEF(he1, he2);
end;

class procedure TEulerOp.KZEV(he: THalfEdge3D);
var
  he1, he2, eTemp: THalfEdge3D;
begin
he1:=he.PrevV;
he2:=he.Sym.PrevV;
eTemp:=he.Sym.NextV;
repeat
  eTemp.SetV(he1.GetV);
  eTemp.Adjacent.Sym.SetV(he1.GetV);
  eTemp:=eTemp.NextV;
until eTemp=he.Sym;

TEulerOp.KEF(he);
TEulerOp.ComplexSplice(he1, he2);
end;

class function TEulerOp.MEF(he1, he2: THalfEdge3D): THalfEdge3D;
//Make Edge Face - create an edge and connect to the existing structure
var
  heN: THalfEdge3D;
begin
heN:=MakeComplexEdge(he1.GetV, he2.GetV, he1.GetVD, he1.Adjacent.GetVD);
TEulerOp.ComplexSplice(heN, he1);
TEulerOp.ComplexSplice(he2, heN.Sym);
Result:=heN;
end;

class procedure TEulerOp.KEF(he: THalfEdge3D);
//Kill Edge Face - reverse to MEF
var
  heSym, heNextF: THalfEdge3D;
begin
//small test(not included in final ver.)::
if (he.NextV=he) or (he.Sym.NextV=he.Sym) then//if one of the ends of the edge is not connected to any other edge then exit
  exit;
//~test
heSym:=he.Sym;
heNextF:=he.NextF;
TEulerOp.ComplexSplice(he, he.Sym.NextF);
TEulerOp.ComplexSplice(heSym, heNextF);
KillComplexEdge(he);
end;

(*
//perhaps this function is useful ???

class function TEulerOp.JoinCells(he1, he2: THalfEdge3D): THalfEdge3D;
//2 cells are in separate cell complexes, result is one solid cell
var
  heTemp: THalfEdge3D;
  edges, edges2: TList;
  i: Integer;
begin
edges:=TList.Create;
edges2:=TList.Create;
heTemp:=he2;
repeat
  edges.Add(heTemp);
  edges.Add(he1.Sym.PrevV);
  edges2.Add(heTemp.Sym.NextV);
  he1:=he1.NextV.Sym;
  heTemp:=heTemp.NextF;
until heTemp=he2;
i:=0;
while i<edges.Count do
  begin
  THalfEdge3D(edges.Items[i]).Splice(edges.Items[i+1]);
  i:=i+2;
  end;
for i:=0 to edges.Count-1 do
  TEulerOp.KEF(edges.Items[i]);
Result:=THalfEdge3D(edges2.Items[0]).Sym.NextV;
for i:=0 to edges2.Count-1 do
  TEulerOp.KVE(edges2.Items[i]);
edges2.Free;
edges.Free;
end;
*)

class procedure TEulerOp.ConnectCellsByFace(he1, he2: THalfEdge3D; _killFace: Boolean=True);
//this function is used in Join and Merge (by face) operation
//
//Join - 2 cells are in separate cell complexes, result is two cells in one cell complex
//this operator links two cells by an adjacent face
//perhaps KGS would be more appropriate name - Kill Genus Shell?
//
//Merge - 2 cells are in the same cell complex, result is one merged cell
//this operator merge two cells by an adjacent face
var
  heTemp, faceToKill, next: THalfEdge3D;
begin
he2:=he2.Sym;
faceToKill:=he1;
heTemp:=he2;
repeat
  if he1<>he2.Sym then
    SnapFaces(he1, he2.Sym);//two adjacent faces
  he1:=he1.NextF;
  he2:=he2.NextV.Sym;//PrevF; //it should be PrevF but we cannot use the dual to navigate here
                 // maybe it would be better to prepare lists of edges to snap and the same with the dual in the next loop
until heTemp=he2;

he1:=he1.NextF;
repeat
  Next:=he1.NextF;
  TEulerOp.QDop(he1, he2);
  he1:=Next;
  he2:=he2.NextV.Sym;//PrevF;
until heTemp=he2;

if _killFace then
  KillFace(faceToKill);
end;

class procedure TEulerOp.MergeCellsByFaceEO(he1, he2: THalfEdge3D);
//2 cells are in 2 different cell complexes, result is one merged cell in one cell complex
//this operator merge two cells by an adjacent face
var
  i: Integer;
  heTemp: THalfEdge3D;
  edges1, edges2: TList;
begin
edges1:=TList.Create;
edges2:=TList.Create;
heTemp:=he2.Sym;
repeat
  edges1.Add(he1);
  edges2.Add(heTemp.NextF);
  he1:=he1.NextV.Sym;
  heTemp:=heTemp.NextF;
until heTemp=he2.Sym;

if edges1.Count>0 then
  edges1.Items[0]:=TEulerOp.MEKFS(edges1.Items[0], edges2.Items[0]);
for i:=1 to edges1.Count-1 do
  edges1.Items[i]:=TEulerOp.MEF(edges1.Items[i], edges2.Items[i]);
for i:=0 to edges2.Count-1 do
  TEulerOp.KEF(edges2.Items[i]);
for i:=0 to edges1.Count-1 do
  TEulerOp.KVE(THalfEdge3D(edges1.Items[i]).Sym);
//if THalfEdge3D.useDual then
  TModel.CalculateAndSetDualForCell(THalfEdge3D(edges1.Items[0]).Sym);
  //TModel.CalculateAndSetDualForCell(he1);

edges2.Free;
edges1.Free;
end;

class procedure TEulerOp.SplitCellsByFace(eList: TList);
var
  i: Integer;
  loopOK: Boolean;
  he2Temp, he2, face, next: THalfEdge3D;
  pList, e2List: TList;
begin
for i:=0 to eList.Count-1 do
  begin
  loopOK:=False;
  he2:=THalfEdge3D(eList.Items[i]).Sym;
  he2Temp:=he2;
  repeat
    if he2Temp=eList.Items[(eList.Count+i-1) mod eList.Count] then
      loopOK:=True
    else
      he2Temp:=he2Temp.NextV;
  until (loopOK or (he2=he2Temp));

  if not loopOK then
    exit;
  end;

pList:=TList.Create;
for i:=0 to eList.Count-1 do
  pList.Add(THalfEdge3D(eList.Items[i]).Sym.GetV);
face:=MakeFace(pList, THalfEdge3D(eList.Items[0]).GetVD).Sym;
pList.Free;

for i:=0 to eList.Count-1 do
  begin
  SnapFaces(eList.Items[i], face);
  face:=face.NextV.Sym;
{  if THalfEdge3D.useDual then
    begin
    TModel.CalculateAndSetDualForCell(he1);
    TModel.CalculateAndSetDualForCell(he2);
    end;
}
  end;
end;

class procedure TEulerOp.SplitCellsByFace(he1, he2: THalfEdge3D);
//a cell is splitting into two, result are two cells in the same complex
//he1 - the first edge of a double-sided face
//he2 - the first edge in splitted cell. Vertices have to be the same as he1
//there shoud be a loop of edges in the splitted cell the same as edges of he1 face
//Explanation:
//the input double-sided face (he1) is like a blade that cut the cell (he2)
//edges of the face should be identical with a loop edges in the cell
//edges in the loop have to be linked together (he2.Sym, he2.Sym.NextV.(NextV)*.Sym, ...)
//
//the perfect situation is when we have a plane and try to find intersection with the cell.
//but it doesn't have to be perfect when cells are concave (more than one intersection).
//when the plane is given, we can calculate intersection and add new edges to the cell,
//then add double-sided face and split the cell.
var
  i: Integer;
  equal: Boolean;
  d: TPoint3D;
  he1Temp, he2Temp, faceToKill, next: THalfEdge3D;
  edges1, edges2: TList;
begin
if (not he1.GetV.Equal(he2.GetV)) or (not he1.Sym.GetV.Equal(he2.Sym.GetV)) then
  exit;
he2:=he2.Sym;

edges1:=TList.Create;
edges2:=TList.Create;
he1Temp:=he1;
repeat
  edges1.Add(he1Temp.Sym);
  equal:=False;
  he2Temp:=he2;
  repeat
    if he2Temp.Sym.GetV.Equal(he1Temp.GetV) then
      begin
      edges2.Add(he2Temp);
      equal:=True;
      end
    else
      he2Temp:=he2Temp.NextV;
  until (equal) or (he2=he2Temp);

  if not equal then
    break;

  he1Temp:=he1Temp.NextV.Sym;
  he2:=he2Temp.Sym.NextV;
until he1Temp=he1;

if edges1.Count=edges2.Count then
  begin
  for i:=0 to edges1.Count-1 do
    begin
    //he2.Adjacent.Sym.SetV(he1.Adjacent.GetV);
    SnapFaces(edges1.Items[i], edges2.Items[i]);
    end;
//  if THalfEdge3D.useDual then
    TModel.CalculateAndSetDualForCell(he1);
//  if THalfEdge3D.useDual then
    TModel.CalculateAndSetDualForCell(he2);
  end;

edges2.Free;
edges1.Free;
end;

class procedure TEulerOp.DisconnectCellsByFace(he1: THalfEdge3D);
//2 cells are in thw same cell complex, result is two separate cells in different cell complexes
//this operator unlinks two cells connected by one adjacent face
//perhaps MGS would be more appropriate name - Make Genus Shell?
var
  heAdj, next, heTemp, newFace, he2: THalfEdge3D;
  vertices: TList;
begin
he2:=he1.Adjacent.Sym;
heAdj:=he1.Adjacent.NextF;
//heAdj:=he2.Sym.NextF;

vertices:=TList.Create;
heTemp:=he1;
repeat
  vertices.Add(he1.GetV);
  he1:=he1.NextV.Sym;
until heTemp=he1;
newFace:=TEulerOp.MakeFace(vertices, TPoint3D.Create(Infinity, Infinity, Infinity, True));//TModel.CalculateDualPointForPolygon(vertices)
vertices.Free;

repeat
  if THalfEdge3D.useDual then
    begin
    TEulerOp.QDop(he1, newFace);
//    TEulerOp.ConnectHEdges(he1.Through.Sym, newFace.NextV.Through);
//    TEulerOp.ConnectHEdges(he1.Through, newFace.Through);
    end
  else
    begin
    next:=heAdj.NextF;

    newFace.NextV.SetDual(heAdj);
    heAdj.SetDual(newFace.NextV);
    he1.SetDual(newFace);
    newFace.SetDual(he1);

    heAdj:=next;
    end;
  newFace:=newFace.Sym.NextV;
  he1:=he1.NextV.Sym;
until heTemp=he1;

heAdj:=he2.Sym;
repeat
  next:=heAdj.NextF; //next variable is necessary only in a case if "not THalfEdge3D.useDual" then
  if he1.Sym.Adjacent.Sym=heAdj.Sym.Adjacent then
    SnapFaces(he1.Adjacent, heAdj.Sym.Adjacent);//heAdj only if "not THalfEdge3D.useDual" otherwise he1.Adjacent.Sym.Adjacent.Sym.Adjacent

  heAdj.Sym.Adjacent.Sym.SetV(heAdj.Sym.getV);

  he1:=he1.NextV.Sym;
  heAdj:=next;
until heTemp=he1;
end;

class procedure TEulerOp.ConnectCellsByEdge(he1, he2: THalfEdge3D);
//this function is used in Join and Merge (by edge) operation
//selfreversible???
//Join - 2 cells are in separate cell complexes, result is two cells in one cell complex
//this operator links two cells by an adjacent edge
//
//Merge - 2 cells are in the same cell complex, result is one merged cell
//this operator merge two cells by an adjacent edge
begin
//if he1.Adjacent<>he2.Adjacent.Sym then
  begin
//  he2.Adjacent.Sym.SetV(he1.Adjacent.GetV);
  SnapFaces(he1, he2);//two adjacent faces
  end;
end;

class procedure TEulerOp.DisconnectCellsByEdge(he1, he2: THalfEdge3D);
//reverse to ConnectCellsByEdge
//var
//  heAdj: THalfEdge3D;
begin
//heAdj:=he1.Adjacent.Sym.Adjacent.Sym;
SnapFaces(he1, he2);//heAdj.Adjacent);
end;

class procedure TEulerOp.MergeCellsByEdge(he1, he2: THalfEdge3D);
//2 cells are in the same cell complex, result is one cell in one cell complex
//this operator links two cells by an adjacent edge
//perhaps KGS would be more appropriate name - Kill Genus Shell?
begin
SnapFaces(he1, he2);
//if THalfEdge3D.useDual then
  //TModel.CalculateAndSetDualForCell(he1);
end;

class procedure TEulerOp.SplitCellsByEdge(he1, he2: THalfEdge3D);
//2 cells are in the same cell complex, result is two cells in two cell complexes
//this operator unlinks two cells by an adjacent edge
//perhaps KGS would be more appropriate name - Kill Genus Shell?
var
  heAdj: THalfEdge3D;
begin
SnapFaces(he1, he2);
//if THalfEdge3D.useDual then
  begin
  TModel.CalculateAndSetDualForCell(he1);
  TModel.CalculateAndSetDualForCell(he2);
  end;

//SnapFaces(he1.Adjacent, he2.Adjacent.Sym);
//heAdj:=he1.Adjacent.Sym.Adjacent.Sym;
//SnapFaces(he1.Adjacent, heAdj.Adjacent);
end;


class procedure TEulerOp.ConnectCellsByVertex(he1, he2: THalfEdge3D);
//this function is used in Join and Merge (by edge) operation
//selfreversible???
//Join - 2 cells are in separate cell complexes, result is two cells in one cell complex
//this operator links two cells by an adjacent vertex
//
//Merge - 2 cells are in the same cell complex, result is one merged cell
//this operator merge two cells by an adjacent vertex
var
  oldUse: Boolean;
begin
oldUse:=THalfEdge3D.useFaceLoops;
THalfEdge3D.useFaceLoops:=False;

TEulerOp.Rop(he1, he2);

THalfEdge3D.useFaceLoops:=oldUse;
end;

class procedure TEulerOp.DisconnectCellsByVertex(he1, he2: THalfEdge3D);
//2 cells are in the same cell complex, result is two cells in two cell complexes
//this operator unlinks two cells by an adjacent vertex
var
  oldUse: Boolean;
begin
oldUse:=THalfEdge3D.useFaceLoops;
THalfEdge3D.useFaceLoops:=False;

TEulerOp.Rop(he1, he2);

THalfEdge3D.useFaceLoops:=oldUse;
end;

class procedure TEulerOp.MergeCellsByVertex(he1, he2: THalfEdge3D);
//2 cells are in the same cell complexes, result is one cells in one cell complex
//this operator links two cells by an adjacent vertex
var
  oldUse: Boolean;
begin
oldUse:=THalfEdge3D.useFaceLoops;
THalfEdge3D.useFaceLoops:=False;

TEulerOp.Rop(he1, he2);

THalfEdge3D.useFaceLoops:=oldUse;

//if THalfEdge3D.useDual then
  begin
  TModel.CalculateAndSetDualForCell(he1);
  end;
end;

class procedure TEulerOp.SplitCellsByVertex(he1, he2: THalfEdge3D);
//one cell in cell complex, result are two cells in one cell complex
//this operator links two cells by an adjacent vertex
var
  oldUse: Boolean;
begin
oldUse:=THalfEdge3D.useFaceLoops;
THalfEdge3D.useFaceLoops:=False;

TEulerOp.Rop(he1, he2);

THalfEdge3D.useFaceLoops:=oldUse;

//if THalfEdge3D.useDual then
  begin
  TModel.CalculateAndSetDualForCell(he1);
  TModel.CalculateAndSetDualForCell(he2);
  end;
end;

class procedure TEulerOp.MergeCellsByVertexEO(he1, he2: THalfEdge3D);
//2 cells are in two complexes, result is one cells in one cell complex
//this operator links two cells by an adjacent vertex
begin
TEulerOp.ComplexSplice(he1, he2);
//TEulerOp.KEV2(TEulerOp.MEKFS(he1, he2));
//TEulerOp.MEF(he1, he2);
end;

class procedure TEulerOp.SplitCellsByVertexEO(he1, he2: THalfEdge3D);
//one cell in cell complex, result are two cells in two cell complexex
//this operator links two cells by an adjacent vertex
begin
TEulerOp.KEMFS(TEulerOp.MZEV(he1.GetV, he1, he2));
end;


class function TEulerOp.KEMFS(he: THalfEdge3D): THalfEdge3D;
//
var
  i: Integer;
  d1, d2: TPoint3D;
  he1, he2: THalfEdge3D;
  tempList: TList;
begin
//calculate new dual points and test if these points are different
he1:=he.PrevV;
he2:=he.Sym.PrevV;

he.Splice(he1);
he.Sym.Splice(he2);
d1:=TModel.CalculateDualPointForPolyhedron(he1);
d2:=TModel.CalculateDualPointForPolyhedron(he2);
he.Splice(he1);
he.Sym.Splice(he2);

if d1.Equal(d2) then
  exit;

TEulerOp.KEF(he);

//join two separate cells - faces has to have the same number of edges (there is no test for that)
he1:=he1.NextV.Sym;
//ConnectCellsByFace(he1, he2.Sym); //connect cells if you want them in one cells complex

//if THalfEdge3D.useDual then
  begin
  TModel.CalculateAndSetDualForCell(he1);
  TModel.CalculateAndSetDualForCell(he2);
  end;

Result:=he1;
end;

class function TEulerOp.MEKFS(he1, he2: THalfEdge3D): THalfEdge3D;
//
var
  i: Integer;
  d: TPoint3D;
  e: THalfEdge3D;
  tempList: TList;
begin
if he1.Adjacent=he2.NextV.Sym then
  DisconnectCellsByFace(he1);
e:=TEulerOp.MEF(he1, he2);

//if THalfEdge3D.useDual then
  TModel.CalculateAndSetDualForCell(he1);
Result:=e;
end;
(********************************~Euler operators ********************************)
(*
Level 3: MakeFace/KillFace, SnapFaces
Level 2: MakeHalfFace/KillHalfFace, ConnectHalfFaces/DisconnectHalfFaces
Level 1: SnapHAQEs/UnsnapHAQEs, ConnectHAQEs/DisconnectHAQEs,
Level 0: MakeHAQE/KillHAQE, SpliceHAQEs, HalfConnectHAQEs, HalfSnapHAQE
*)
(********************************Level 2********************************)
class function TEulerOp.MakeComplexEdge(p1, p2, pIn, pOut: TPoint3D): THalfEdge3D;
var
  eIn, eOut: THalfEdge3D;
begin
//eIn:=MakeDegenerateEdge(p1);

eIn:=MakeEdge(p1, p2, pIn);
eOut:=MakeEdge(p1, p2, pOut);
QDop(eIn, eOut);
{
if THalfEdge3D.useDual and THalfEdge3D.useFaceLoops then
  begin
  eIn.Dual.SetNextF(eIn.Dual.Sym);
  eIn.Dual.Sym.SetNextF(eIn.Dual);
  eOut.Dual.SetNextF(eOut.Dual.Sym);
  eOut.Dual.Sym.SetNextF(eOut.Dual);
  end;
}
Result:=eIn;
end;

class function TEulerOp.KillComplexEdge(eIn: THalfEdge3D): THalfEdge3D;
var
  eOut: THalfEdge3D;
begin
eOut:=eIn.Adjacent;
//dual - it isn't neccesery to disconnect two adjacent HEdges because we can only disconnect free edge - not connected to any other
KillEdge(eIn);
KillEdge(eOut);
end;

class function TEulerOp.MakeFace(pList: TList; v: TPoint3D):THalfEdge3D;
var
  i: Integer;
  pArr: array of TPoint3D;
begin
SetLength(pArr, pList.Count);
for i:=0 to pList.Count-1 do
  pArr[i]:=pList.Items[i];
Result:=TEulerOp.MakeFace(pArr, v);
end;

class function TEulerOp.MakeFace(pArr: array of TPoint3D; v: TPoint3D):THalfEdge3D;
var
  i, count: Integer;
  pTemp: TPoint3D;
  e1, e2, e1Sym, e2Sym: THalfEdge3D;
  edges: TList;
begin
e1:=TEulerOp.MakeDegenerateEdge(pArr[0], v).NextV;
count:=High(pArr)+1;
for i:=1 to count-1 do
  begin
  e2:=TEulerOp.MakeDegenerateEdge(pArr[i], v);
  e1Sym:=e1.Sym;
  e2Sym:=e2.Sym;
  TEulerOp.QPop(e1, e2);
{  if THalfEdge3D.useFaceLoops then
    begin
    e2Sym.SetNextF(e1Sym.NextF);
    e1Sym.SetNextF(e2Sym);
    e2.SetNextF(e1.NextF);
    e1.SetNextF(e2);
    end;
}
  end;
Result:=e1.NextV;
end;

class procedure TEulerOp.KillFace(he: THalfEdge3D);
var
  heFirst, hePrev: THalfEdge3D;
begin
//antiface:=f.Rot.getAdjacent.InvRot;
heFirst:=he.Sym;
while he.NextV<>heFirst do
  begin
  hePrev:=he;
  he:=he.NextV.Sym;
  TEulerOp.KillEdge(hePrev);
  end;
TEulerOp.KillEdge(he);
end;

class procedure TEulerOp.SnapFaces(he1, he2Sym: THalfEdge3D);  //function sew Operator
var
  he1Sym, he2, he1PrevV, he2PrevV, he1SymPrevV, he2SymPrevV: THalfEdge3D;
begin
{
e1Sym:=e1.Sym; e2:=e2Sym.Sym;
e1PrevV:=e1.PrevV; e2PrevV:=e2.PrevV;
e1SymPrevV:=e1Sym.PrevV; e2SymPrevV:=e2Sym.PrevV;
Snap(he1, he2Sym);
Splice(he1PrevV, he2SymPrevV);
Splice(he1SymPrevV, he2PrevV);
}
he1Sym:=he1.Sym;       //e1sym:=e1.sym
he2:=he2Sym.Sym;       //e2:=e2Sym.Sym
he1PrevV:=he1.PrevV;   //e1PrevV:=e1.PrevV
he2PrevV:=he2.PrevV;   //e2PrevV:=e2.PrevV
he1SymPrevV:=he1Sym.PrevV; //e1symPrevV:=e1.Sym.PrevV
he2SymPrevV:=he2Sym.PrevV; //e2SymPrevV:=e2Sym.PrevV

TEulerOp.QPop(he1, he2Sym); //Snap  (he1PrevV,he2SymPrevV)
TEulerOp.Rop(he1PrevV, he2SymPrevV); //Splice(he1PrevV,he2SymPrevV)
TEulerOp.Rop(he1SymPrevV, he2PrevV);   //Splice(he1SymPrevV,he2PrevV)
end;

(********************************~Level 2********************************)


(***********************************************************************)
(***********************************************************************)
(***********************************************************************)
(***********************************************************************)
(***********************************************************************)
(***********************************************************************)



(********************************Level 2********************************)
class procedure TEulerOp.ComplexSplice(he1In, he2In: THalfEdge3D);
var
  he2NextOut, he1NextOut: THalfEdge3D;
begin
//he1NextOut:=he1In.Adjacent.Sym.PrevV;
//he2NextOut:=he2In.Adjacent.Sym.PrevV;
if THalfEdge3D.useDual then
  begin
  he1NextOut:=he1In.Dual.Sym.Dual;
  he2NextOut:=he2In.Dual.Sym.Dual;
  end
else
  begin
  he1NextOut:=he1In.Dual;
  he2NextOut:=he2In.Dual;
  end;

Rop(he1In, he2In);
Rop(he1NextOut, he2NextOut);
QDop(he1In, he2NextOut);
QDop(he2In, he1NextOut);//?????
end;

class procedure TEulerOp.Rop(e1, e2: THalfEdge3D);
var
  eTemp1, eTemp2: THalfEdge3D;
begin
if THalfEdge3D.useDual then
  TEulerOp.Sop(e1.NextV.Dual, e2.NextV.Dual);
//  end;
TEulerOp.Sop(e1, e2);
end;

class procedure TEulerOp.Sop(e1, e2: THalfEdge3D);
begin
e1.Splice(e2);
end;

class procedure TEulerOp.QPop(e1, e2: THalfEdge3D);
var
  eTemp: THalfEdge3D;
begin
if THalfEdge3D.useFaceLoops then
  begin
  eTemp:=e1.Sym.NextF;
  e1.Sym.SetNextF(e2.Sym.NextF);
  e2.Sym.SetNextF(eTemp);

  eTemp:=e1.NextF;
  e1.SetNextF(e2.NextF);
  e2.SetNextF(eTemp);
  end;

eTemp:=e1.Sym;
ConnectHEdges(e1, e2.Sym);
ConnectHEdges(e2, eTemp);
end;

class procedure TEulerOp.QDop(e1, e2: THalfEdge3D);  //connect dual operator
var
  eTemp: THalfEdge3D;
begin
if THalfEdge3D.useDual then
  begin
  QPop(e1.Dual.Sym, e2.Dual);
  //ConnectHEdges(e1.Dual.Sym, e2.Dual.Sym);
  //ConnectHEdges(e1.Dual, e2.Dual);
  end
else
  begin
  {e1.Dual.SetDual(e2.Dual);
  e2.Dual.SetDual(e1.Dual);
  e1.SetDual(e2);
  e2.SetDual(e1); }
  eTemp:=e1.Dual;
  e1.Dual.SetDual(e2.Dual);
  e2.Dual.SetDual(eTemp);
  e1.SetDual(e2);
  e2.SetDual(e1);
  end;
end;
(********************************~Level 2********************************)
(*********************************Level 1********************************)
class function TEulerOp.MakeDegenerateEdge(p, d: TPoint3D; f:Integer=0): THalfEdge3D;
var
  he, heSym: THalfEdge3D;
begin
he:=MakeHEdge(p, d, f);
heSym:=MakeHEdge(p, d, f);
ConnectHEdges(he, heSym);
he.Splice(heSym);
if THalfEdge3D.useDual then
  begin
  ConnectHEdges(he.Dual, heSym.Dual);
  he.Dual.Splice(heSym.Dual);
  end
else
  begin
  he.SetDual(heSym);
  heSym.SetDual(he);
  end;
Result:=he;
end;

class procedure TEulerOp.KillDegenerateEdge(e: THalfEdge3D);
var
  eSym: THalfEdge3D;
begin
eSym:=e.Sym;
DisconnectHEdges(e);
KillHEdge(e);
KillHEdge(eSym);
end;

class function TEulerOp.MakeEdge(p1, p2, d: TPoint3D; f:Integer=0): THalfEdge3D;
var
  he, heSym: THalfEdge3D;
begin
he:=MakeHEdge(p1, d, f);
heSym:=MakeHEdge(p2, d, f);
ConnectHEdges(he, heSym);
if THalfEdge3D.useFaceLoops then
  begin
  he.SetNextF(heSym);
  heSym.SetNextF(he);
  end;
if THalfEdge3D.useDual then
  begin
  ConnectHEdges(he.Dual, heSym.Dual);
  if THalfEdge3D.useFaceLoops then
    begin
    he.Dual.SetNextF(heSym.Dual);
    heSym.Dual.SetNextF(he.Dual);
    end;
  if f=2 then
    begin
    SOp(he.Dual, heSym.Dual);
    he.Dual.SetDual(heSym);
    heSym.Dual.SetDual(he);
    end;
//  he.Through.Splice(heSym.Through);
  end
else
  begin
  he.SetDual(heSym);
  heSym.SetDual(he);
  end;

Result:=he;
end;

class procedure TEulerOp.KillEdge(e: THalfEdge3D);
var
  eSym: THalfEdge3D;
begin
eSym:=e.Sym;
DisconnectHEdges(e);
KillHEdge(e);
KillHEdge(eSym);
end;
(********************************~Level 1********************************)
(********************************Level 0********************************)

class procedure TEulerOp.ConnectHEdges(he1, he2: THalfEdge3D);
begin
he1.SetSym(he2);
he2.SetSym(he1);
end;

class procedure TEulerOp.DisconnectHEdges(he1: THalfEdge3D);
var
  he2: THalfEdge3D;
begin
he2:=he1.Sym;
he1.SetSym(he1);
he2.SetSym(he2);
end;

class function TEulerOp.MakeHEdge(p, d: TPoint3D; f:Integer=0): THalfEdge3D;
//MakeEdge:
//Q0:=MakeHalfEdge(orig, v1);
//Q1:=MakeHalfEdge(dest, v2);
//Q0.ConnectHalfEdge(Q1);
var
  heP, heD: THalfEdge3D;
begin
heP:=THalfEdge3D.Create;
heP.SetNext(heP);
heP.SetSym(heP);
heP.setV(p);
if THalfEdge3D.useFaceLoops then
  heP.SetNextF(heP);
heP.SetTypeFlag(f);
if THalfEdge3D.useDual then
  begin
  heD:=THalfEdge3D.Create;
  heD.SetNext(heD);
  heD.SetSym(heD);
  heD.setV(d);
  if THalfEdge3D.useFaceLoops then
    heD.SetNextF(heD);
  heP.SetDual(heD);
  heD.SetDual(heP);
  heD.SetTypeFlag(f);
  end
else
  begin
  heP.SetDual(heP);
  heP.SetVD(d);
  end;

Result:=heP;
end;

class procedure TEulerOp.KillHEdge(he: THalfEdge3D);
begin
THalfEdge3D.DestroyHEdge(he);
end;
(********************************~Level 0********************************)
end.
