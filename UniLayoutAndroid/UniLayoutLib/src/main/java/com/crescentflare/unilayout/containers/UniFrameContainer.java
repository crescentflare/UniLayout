package com.crescentflare.unilayout.containers;

import android.content.Context;
import android.graphics.Point;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;

import com.crescentflare.unilayout.helpers.UniLayoutParams;

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

        // Iterate over subviews and layout each one
        int childCount = getChildCount();
        for (int i = 0; i < childCount; i++)
        {
            // Skip hidden views if they are not part of the layout
            View view = getChildAt(i);
            if (view.getVisibility() == GONE)
            {
                continue;
            }

            // Adjust size limitations based on layout property restrictions
            ViewGroup.LayoutParams viewLayoutParams = view.getLayoutParams();
            int viewWidthSpec = widthSpec == MeasureSpec.UNSPECIFIED ? MeasureSpec.UNSPECIFIED : MeasureSpec.AT_MOST;
            int viewHeightSpec = heightSpec == MeasureSpec.UNSPECIFIED ? MeasureSpec.UNSPECIFIED : MeasureSpec.AT_MOST;
            int viewWidthSize = paddedWidthSize;
            int viewHeightSize = paddedHeightSize;
            int viewMinWidth = 0;
            int viewMaxWidth = 0xFFFFFF;
            int viewMinHeight = 0;
            int viewMaxHeight = 0xFFFFFF;
            if (viewLayoutParams instanceof UniLayoutParams)
            {
                viewMinWidth = ((UniLayoutParams)viewLayoutParams).minWidth;
                viewMaxWidth = ((UniLayoutParams)viewLayoutParams).maxWidth;
                viewMinHeight = ((UniLayoutParams)viewLayoutParams).minHeight;
                viewMaxHeight = ((UniLayoutParams)viewLayoutParams).maxHeight;
            }
            if (viewLayoutParams instanceof MarginLayoutParams)
            {
                viewWidthSize = Math.max(0, viewWidthSize - ((MarginLayoutParams)viewLayoutParams).leftMargin - ((MarginLayoutParams)viewLayoutParams).rightMargin);
                viewHeightSize = Math.max(0, viewHeightSize - ((MarginLayoutParams)viewLayoutParams).topMargin - ((MarginLayoutParams)viewLayoutParams).bottomMargin);
            }
            if (widthSpec == MeasureSpec.EXACTLY && viewLayoutParams.width == ViewGroup.LayoutParams.MATCH_PARENT)
            {
                viewWidthSize = Math.min(viewWidthSize, Math.max(viewMinWidth, viewMaxWidth));
                viewWidthSpec = MeasureSpec.EXACTLY;
            }
            else if (viewLayoutParams.width >= 0)
            {
                viewWidthSize = Math.min(viewWidthSize, Math.max(viewMinWidth, Math.min(viewLayoutParams.width, viewMaxWidth)));
                viewWidthSpec = MeasureSpec.EXACTLY;
            }
            else
            {
                viewWidthSize = Math.min(viewWidthSize, Math.max(viewMinWidth, viewMaxWidth));
            }
            if (heightSpec == MeasureSpec.EXACTLY && viewLayoutParams.height == ViewGroup.LayoutParams.MATCH_PARENT)
            {
                viewHeightSize = Math.min(viewHeightSize, Math.max(viewMinHeight, viewMaxHeight));
                viewHeightSpec = MeasureSpec.EXACTLY;
            }
            else if (viewLayoutParams.height >= 0)
            {
                viewHeightSize = Math.min(viewHeightSize, Math.max(viewMinHeight, Math.min(viewLayoutParams.height, viewMaxHeight)));
                viewHeightSpec = MeasureSpec.EXACTLY;
            }
            else
            {
                viewHeightSize = Math.min(viewHeightSize, Math.max(viewMinHeight, viewMaxHeight));
            }

            // Obtain final size and make final adjustments per view
            view.measure(MeasureSpec.makeMeasureSpec(viewWidthSize, viewWidthSpec), MeasureSpec.makeMeasureSpec(viewHeightSize, viewHeightSpec));
            int resultWidth = view.getMeasuredWidth();
            int resultHeight = view.getMeasuredHeight();
            int x = getPaddingLeft();
            int y = getPaddingTop();
            resultWidth = Math.min(viewWidthSize, Math.max(viewMinWidth, resultWidth));
            resultHeight = Math.min(viewHeightSize, Math.max(viewMinHeight, resultHeight));
            if (viewLayoutParams instanceof MarginLayoutParams)
            {
                x += ((MarginLayoutParams)viewLayoutParams).leftMargin;
                y += ((MarginLayoutParams)viewLayoutParams).topMargin;
                if (adjustLayout && viewLayoutParams instanceof UniLayoutParams)
                {
                    UniLayoutParams uniLayoutParams = (UniLayoutParams)viewLayoutParams;
                    x += (paddedWidthSize - uniLayoutParams.leftMargin - uniLayoutParams.rightMargin - resultWidth) * uniLayoutParams.horizontalGravity;
                    y += (paddedHeightSize - uniLayoutParams.topMargin - uniLayoutParams.bottomMargin - resultHeight) * uniLayoutParams.verticalGravity;
                }
                measuredSize.x = Math.max(measuredSize.x, x + resultWidth + ((MarginLayoutParams)viewLayoutParams).rightMargin);
                measuredSize.y = Math.max(measuredSize.y, y + resultHeight + ((MarginLayoutParams)viewLayoutParams).bottomMargin);
            }
            else
            {
                measuredSize.x = Math.max(measuredSize.x, x + resultWidth);
                measuredSize.y = Math.max(measuredSize.y, y + resultHeight);
            }
            if (adjustLayout)
            {
                view.layout(x, y, x + resultWidth, y + resultHeight);
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
