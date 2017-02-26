package com.crescentflare.unilayout.containers;

import android.content.Context;
import android.graphics.Point;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;

import com.crescentflare.unilayout.helpers.UniLayoutParams;
import com.crescentflare.unilayout.helpers.UniLayout;
import com.crescentflare.unilayout.views.UniView;

/**
 * UniLayout container: an overlapping view container
 * Overlaps and aligns views within the container
 */
public class UniFrameContainer extends ViewGroup
{
    // ---
    // Initialization
    // ---

    public UniFrameContainer(Context context)
    {
        this(context, (AttributeSet)null);
    }

    public UniFrameContainer(Context context, AttributeSet attrs)
    {
        super(context, attrs);
        init(attrs);
    }

    public UniFrameContainer(Context context, AttributeSet attrs, int defStyleAttr)
    {
        this(context, attrs);
    }

    public UniFrameContainer(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes)
    {
        this(context, attrs);
    }

    private void init(AttributeSet attrs)
    {
    }

    @Override
    protected LayoutParams generateDefaultLayoutParams()
    {
        return new UniLayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
    }

    @Override
    public LayoutParams generateLayoutParams(AttributeSet attrs)
    {
        return new UniLayoutParams(getContext(), attrs);
    }


    // ---
    // Custom layout
    // ---

    private Point measuredSize = new Point();

    private void performLayout(Point measuredSize, int widthSize, int heightSize, int widthSpec, int heightSpec, boolean adjustLayout)
    {
        // Determine available size without padding
        int paddedWidthSize = widthSize - getPaddingLeft() - getPaddingRight();
        int paddedHeightSize = heightSize - getPaddingTop() - getPaddingBottom();
        measuredSize.x = getPaddingLeft();
        measuredSize.y = getPaddingTop();
        if (widthSpec == MeasureSpec.UNSPECIFIED)
        {
            paddedWidthSize = 0xFFFFFF;
        }
        if (heightSpec == MeasureSpec.UNSPECIFIED)
        {
            paddedHeightSize = 0xFFFFFF;
        }

        // Iterate over subviews and measure each one
        int childCount = getChildCount();
        for (int i = 0; i < childCount; i++)
        {
            // Skip hidden views if they are not part of the layout
            View view = getChildAt(i);
            if (view.getVisibility() == GONE)
            {
                continue;
            }

            // Perform measure
            ViewGroup.LayoutParams viewLayoutParams = view.getLayoutParams();
            int limitWidth = paddedWidthSize;
            int limitHeight = paddedHeightSize;
            if (viewLayoutParams instanceof MarginLayoutParams)
            {
                limitWidth -= ((MarginLayoutParams)viewLayoutParams).leftMargin + ((MarginLayoutParams)viewLayoutParams).rightMargin;
                limitHeight -= ((MarginLayoutParams)viewLayoutParams).topMargin + ((MarginLayoutParams)viewLayoutParams).bottomMargin;
            }
            UniLayout.measure(view, limitWidth, limitHeight, widthSpec, heightSpec, MeasureSpec.UNSPECIFIED, MeasureSpec.UNSPECIFIED);
        }

        // Start doing layout
        for (int i = 0; i < childCount; i++)
        {
            // Skip hidden views if they are not part of the layout
            View view = getChildAt(i);
            if (view.getVisibility() == GONE)
            {
                continue;
            }

            // Continue with the others
            ViewGroup.LayoutParams viewLayoutParams = view.getLayoutParams();
            int width = view.getMeasuredWidth();
            int height = view.getMeasuredHeight();
            int x = getPaddingLeft();
            int y = getPaddingTop();
            if (viewLayoutParams instanceof MarginLayoutParams)
            {
                x += ((MarginLayoutParams)viewLayoutParams).leftMargin;
                y += ((MarginLayoutParams)viewLayoutParams).topMargin;
                if (adjustLayout && viewLayoutParams instanceof UniLayoutParams)
                {
                    UniLayoutParams uniLayoutParams = (UniLayoutParams)viewLayoutParams;
                    x += (paddedWidthSize - uniLayoutParams.leftMargin - uniLayoutParams.rightMargin - width) * uniLayoutParams.horizontalGravity;
                    y += (paddedHeightSize - uniLayoutParams.topMargin - uniLayoutParams.bottomMargin - height) * uniLayoutParams.verticalGravity;
                }
                measuredSize.x = Math.max(measuredSize.x, x + width + ((MarginLayoutParams)viewLayoutParams).rightMargin);
                measuredSize.y = Math.max(measuredSize.y, y + height + ((MarginLayoutParams)viewLayoutParams).bottomMargin);
            }
            else
            {
                measuredSize.x = Math.max(measuredSize.x, x + width);
                measuredSize.y = Math.max(measuredSize.y, y + height);
            }
            if (adjustLayout)
            {
                view.layout(x, y, x + width, y + height);
            }
        }

        // Adjust final measure with padding and limitations
        measuredSize.x += getPaddingRight();
        measuredSize.y += getPaddingBottom();
        if (widthSpec == MeasureSpec.EXACTLY)
        {
            measuredSize.x = widthSize;
        }
        else if (widthSpec == MeasureSpec.AT_MOST)
        {
            measuredSize.x = Math.min(measuredSize.x, widthSize);
        }
        if (heightSpec == MeasureSpec.EXACTLY)
        {
            measuredSize.y = heightSize;
        }
        else if (heightSpec == MeasureSpec.AT_MOST)
        {
            measuredSize.y = Math.min(measuredSize.y, heightSize);
        }
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec)
    {
        performLayout(measuredSize, MeasureSpec.getSize(widthMeasureSpec), MeasureSpec.getSize(heightMeasureSpec), MeasureSpec.getMode(widthMeasureSpec), MeasureSpec.getMode(heightMeasureSpec), false);
        setMeasuredDimension(measuredSize.x, measuredSize.y);
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom)
    {
        performLayout(measuredSize, right - left, bottom - top, MeasureSpec.EXACTLY, MeasureSpec.EXACTLY, true);
    }
}
