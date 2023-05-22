Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using System.Threading;

public class CursorMover
{
    private const int SM_XVIRTUALSCREEN = 76;
    private const int SM_YVIRTUALSCREEN = 77;
    private const int SM_CXVIRTUALSCREEN = 78;
    private const int SM_CYVIRTUALSCREEN = 79;
    private const int MouseMoveDuration = 1000; // Duration for cursor movement in milliseconds

    [DllImport("user32.dll")]
    private static extern bool SetCursorPos(int x, int y);

    [DllImport("user32.dll")]
    private static extern bool GetCursorPos(out POINT lpPoint);

    [DllImport("user32.dll")]
    private static extern int GetSystemMetrics(int nIndex);

    [StructLayout(LayoutKind.Sequential)]
    public struct POINT
    {
        public int X;
        public int Y;
    }

    public static void MoveCursor(int targetX, int targetY)
    {
        POINT currentPos;
        GetCursorPos(out currentPos);

        int stepSizeX = (targetX - currentPos.X) / MouseMoveDuration;
        int stepSizeY = (targetY - currentPos.Y) / MouseMoveDuration;

        for (int i = 0; i < MouseMoveDuration; i++)
        {
            int newX = currentPos.X + (stepSizeX * i);
            int newY = currentPos.Y + (stepSizeY * i);
            SetCursorPos(newX, newY);
            Thread.Sleep(1);
        }

        // Move the cursor to the target position precisely
        SetCursorPos(targetX, targetY);
    }

    public static int GetRandomCoordinate(int min, int max)
    {
        Random random = new Random();
        return random.Next(min, max);
    }

    public static int GetVirtualScreenLeft()
    {
        return GetSystemMetrics(SM_XVIRTUALSCREEN);
    }

    public static int GetVirtualScreenTop()
    {
        return GetSystemMetrics(SM_YVIRTUALSCREEN);
    }

    public static int GetVirtualScreenWidth()
    {
        return GetSystemMetrics(SM_CXVIRTUALSCREEN);
    }

    public static int GetVirtualScreenHeight()
    {
        return GetSystemMetrics(SM_CYVIRTUALSCREEN);
    }
}

public class CursorMoverScript
{
    private int interval;
    private int screenLeft;
    private int screenTop;
    private int screenWidth;
    private int screenHeight;

    public CursorMoverScript(int interval)
    {
        this.interval = interval;

        this.screenLeft = CursorMover.GetVirtualScreenLeft();
        this.screenTop = CursorMover.GetVirtualScreenTop();
        this.screenWidth = CursorMover.GetVirtualScreenWidth();
        this.screenHeight = CursorMover.GetVirtualScreenHeight();
    }

    public void StartMovingCursor()
    {
        while (true)
        {
            MoveCursor();
            Thread.Sleep(this.interval * 1000);
        }
    }

    private void MoveCursor()
    {
        var targetX = CursorMover.GetRandomCoordinate(this.screenLeft, this.screenLeft + this.screenWidth);
        var targetY = CursorMover.GetRandomCoordinate(this.screenTop, this.screenTop + this.screenHeight);
        CursorMover.MoveCursor(targetX, targetY);
    }
}
"@

$IntervalInSeconds = 60  # Change this to the desired interval in seconds

$script = New-Object CursorMoverScript($IntervalInSeconds)
$script.StartMovingCursor()
