#ifndef FILE
#define FILE
class Pixel
{
    private:
        Coordinate x;
        Coordinate *y;
        const Color color;
        int index;
        /* Aint something_else; */
    public:
        Pixel(Space s);
        virtual ~Pixel();
        void SetX(Coordinate *xx, int *y, Pix *px) {x = xx;}

        Point a, * p, b, bb, *c;

        const unsigned long long int *haba;

        AltTip membru1;

        const Point* makePoint(const TipConstant *tt);
        signed long long *testM ( TipA v1, unsigned long long int nr, TipB v2){};

        TipLung v1,v2,v3, *  v4;
int * GetX();
void *SetY(Coordinate yy) {y = yy;}
int GetY();
};
class Line : Pixel
{
    private:
        Pixel p1;
        Pixel p2;
    public:
        Line();
        void SetP1(Pixel p1);
        int GetP1();
         void SetP2(Pixel p2);
         int GetP2();
        Line GetCopy();
};

