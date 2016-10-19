package com.crescentflare.unilayout.containers;

import android.content.Context;
import android.graphics.Point;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import com.crescentflare.unilayout.helpers.UniLayoutParams;

import java.util.ArrayList;
import java.util.List;

/**
 * UniLayout container: a vertically or horizontally aligned view container
 * Stacks views below or to the right of each other
 */
public class UniLinearContainer extends LinearLayout
{
    // ---
    // Initialization
    // ---

    public UniLinearContainer(Context context)
    {
        this(context, (AttributeSet)null);
    }

    public UniLinearContainer(Context context, AttributeSet attrs)
    {
        super(context, attrs);
        init(attrs);
    }

    public UniLinearContainer(Context context, AttributeSet attrs, int defStyleAttr)
    {
        this(context, attrs);
    }

    public UniLinearContainer(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes)
    {
        this(context, attrs);
    }

    private void init(AttributeSet attrs)
    {
        setOrientation(VERTICAL);
    }


    // ---
    // Custom layout
    // ---

    private Point measuredSize = new Point();
    private List<Point> measuredChildSizes = new ArrayList<>();

    private void performVerticalLayout(Point measuredSize, int widthSize, int heightSize, int widthSpec, int heightSpec, boolean adjustLayout)
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

        // Measure the views without any weight
        float totalWeight = 0;
        int remainingHeight = paddedHeightSize;
        float totalMinHeightForWeight = 0;
        int childCount = getChildCount();
        prepareChildSizes(childCount);
        for (int i = 0; i < childCount; i++)
        {
            // Skip hidden views if they are not part of the layout
            View view = getChildAt(i);
            if (view.getVisibility() == GONE)
            {
                continue;
            }

            // Skip views with weight, they will go in the second phase
            ViewGroup.LayoutParams viewLayoutParams = view.getLayoutParams();
            if (viewLayoutParams instanceof UniLayoutParams)
            {
                UniLayoutParams uniLayoutParams = (UniLayoutParams)viewLayoutParams;
                if (uniLayoutParams.weight > 0)
                {
                    totalWeight += uniLayoutParams.weight;
                    remainingHeight -= uniLayoutParams.topMargin + uniLayoutParams.bottomMargin + uniLayoutParams.minHeight;
                    totalMinHeightForWeight += uniLayoutParams.minHeight;
                    measuredChildSizes.get(i).set(0, 0);
                    continue;
                }
            }

            // Adjust size limitations based on layout property restrictions
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
            if (viewLayoutParams.height >= 0)
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
            resultWidth = Math.min(viewWidthSize, Math.max(viewMinWidth, resultWidth));
            resultHeight = Math.min(viewHeightSize, Math.max(viewMinHeight, resultHeight));
            if (viewLayoutParams instanceof MarginLayoutParams)
            {
                remainingHeight -= ((MarginLayoutParams)viewLayoutParams).topMargin + ((MarginLayoutParams)viewLayoutParams).bottomMargin;
            }
            measuredChildSizes.get(i).set(resultWidth, resultHeight);
            remainingHeight -= resultHeight;
        }

        // Measure the remaining views with weight
        remainingHeight += totalMinHeightForWeight;
        for (int i = 0; i < childCount; i++)
        {
            // Skip hidden views if they are not part of the layout
            View view = getChildAt(i);
            if (view.getVisibility() == GONE)
            {
                continue;
            }

            // Continue with views with weight
            if (view.getLayoutParams() instanceof UniLayoutParams)
            {
                UniLayoutParams uniLayoutParams = (UniLayoutParams)view.getLayoutParams();
                if (uniLayoutParams.weight > 0)
                {
                    // Adjust size limitations based on layout property restrictions
                    int wantHeight = (int)(remainingHeight * uniLayoutParams.weight / totalWeight);
                    int viewWidthSpec = widthSpec == MeasureSpec.UNSPECIFIED ? MeasureSpec.UNSPECIFIED : MeasureSpec.AT_MOST;
                    int viewHeightSpec = heightSpec == MeasureSpec.UNSPECIFIED ? MeasureSpec.UNSPECIFIED : MeasureSpec.AT_MOST;
                    int viewWidthSize = paddedWidthSize;
                    int viewHeightSize = remainingHeight;
                    viewWidthSize = Math.max(0, viewWidthSize - uniLayoutParams.leftMargin - uniLayoutParams.rightMargin);
                    viewHeightSize = Math.max(0, viewHeightSize - uniLayoutParams.topMargin - uniLayoutParams.bottomMargin);
                    if (widthSpec == MeasureSpec.EXACTLY && uniLayoutParams.width == ViewGroup.LayoutParams.MATCH_PARENT)
                    {
                        viewWidthSize = Math.min(viewWidthSize, Math.max(uniLayoutParams.minWidth, uniLayoutParams.maxWidth));
                        viewWidthSpec = MeasureSpec.EXACTLY;
                    }
                    else if (uniLayoutParams.width >= 0)
                    {
                        viewWidthSize = Math.min(viewWidthSize, Math.max(uniLayoutParams.minWidth, Math.min(uniLayoutParams.width, uniLayoutParams.maxWidth)));
                        viewWidthSpec = MeasureSpec.EXACTLY;
                    }
                    else
                    {
                        viewWidthSize = Math.min(viewWidthSize, Math.max(uniLayoutParams.minWidth, uniLayoutParams.maxWidth));
                    }
                    viewHeightSize = Math.min(viewHeightSize, Math.max(uniLayoutParams.minHeight, Math.min(wantHeight, uniLayoutParams.maxHeight)));
                    viewHeightSpec = MeasureSpec.EXACTLY;

                    // Obtain final size and make final adjustments per view
                    view.measure(MeasureSpec.makeMeasureSpec(viewWidthSize, viewWidthSpec), MeasureSpec.makeMeasureSpec(viewHeightSize, viewHeightSpec));
                    int resultWidth = view.getMeasuredWidth();
                    int resultHeight = view.getMeasuredHeight();
                    if (!adjustLayout)
                    {
                        resultHeight = 0;
                    }
                    resultWidth = Math.min(viewWidthSize, Math.max(uniLayoutParams.minWidth, resultWidth));
                    resultHeight = Math.min(viewHeightSize, Math.max(uniLayoutParams.minHeight, resultHeight));
                    remainingHeight -= uniLayoutParams.topMargin + uniLayoutParams.bottomMargin;
                    measuredChildSizes.get(i).set(resultWidth, resultHeight);
                    remainingHeight -= resultHeight;
                    totalWeight -= uniLayoutParams.weight;
                }
            }
        }

        // Start doing layout
        int y = getPaddingTop();
        for (int i = 0; i < childCount; i++)
        {
            // Skip hidden views if they are not part of the layout
            View view = getChildAt(i);
            if (view.getVisibility() == GONE)
            {
                continue;
            }

            // Continue with the others
            Point size = measuredChildSizes.get(i);
            int x = getPaddingLeft();
            int nextY = y;
            if (view.getLayoutParams() instanceof UniLayoutParams)
            {
                UniLayoutParams uniLayoutParams = (UniLayoutParams)view.getLayoutParams();
                x += uniLayoutParams.leftMargin;
                y += uniLayoutParams.topMargin;
                if (adjustLayout)
                {
                    x += (paddedWidthSize - uniLayoutParams.leftMargin - uniLayoutParams.rightMargin - size.x) * uniLayoutParams.horizontalGravity;
                }
                measuredSize.x = Math.max(measuredSize.x, x + size.x + uniLayoutParams.rightMargin);
                nextY = y + size.y + uniLayoutParams.bottomMargin;
            }
            else
            {
                measuredSize.x = Math.max(measuredSize.x, x + size.x);
                nextY = y + size.y;
            }
            if (adjustLayout)
            {
                view.layout(x, y, x + size.x, y + size.y);
            }
            measuredSize.y = Math.max(measuredSize.y, nextY);
            y = nextY;
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

    private void performHorizontalLayout(Point measuredSize, int widthSize, int heightSize, int widthSpec, int heightSpec, boolean adjustLayout)
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

        // Measure the views without any weight
        float totalWeight = 0;
        int remainingWidth = paddedWidthSize;
        float totalMinWidthForWeight = 0;
        int childCount = getChildCount();
        prepareChildSizes(childCount);
        for (int i = 0; i < childCount; i++)
        {
            // Skip hidden views if they are not part of the layout
            View view = getChildAt(i);
            if (view.getVisibility() == GONE)
            {
                continue;
            }

            // Skip views with weight, they will go in the second phase
            ViewGroup.LayoutParams viewLayoutParams = view.getLayoutParams();
            if (viewLayoutParams instanceof UniLayoutParams)
            {
                UniLayoutParams uniLayoutParams = (UniLayoutParams)viewLayoutParams;
                if (uniLayoutParams.weight > 0)
                {
                    totalWeight += uniLayoutParams.weight;
                    remainingWidth -= uniLayoutParams.leftMargin + uniLayoutParams.rightMargin + uniLayoutParams.minWidth;
                    totalMinWidthForWeight += uniLayoutParams.minWidth;
                    measuredChildSizes.get(i).set(0, 0);
                    continue;
                }
            }

            // Adjust size limitations based on layout property restrictions
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
            if (viewLayoutParams.width >= 0)
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
            resultWidth = Math.min(viewWidthSize, Math.max(viewMinWidth, resultWidth));
            resultHeight = Math.min(viewHeightSize, Math.max(viewMinHeight, resultHeight));
            if (viewLayoutParams instanceof MarginLayoutParams)
            {
                remainingWidth -= ((MarginLayoutParams)viewLayoutParams).leftMargin + ((MarginLayoutParams)viewLayoutParams).rightMargin;
            }
            measuredChildSizes.get(i).set(resultWidth, resultHeight);
            remainingWidth -= resultWidth;
        }

        // Measure the remaining views with weight
        remainingWidth += totalMinWidthForWeight;
        for (int i = 0; i < childCount; i++)
        {
            // Skip hidden views if they are not part of the layout
            View view = getChildAt(i);
            if (view.getVisibility() == GONE)
            {
                continue;
            }

            // Continue with views with weight
            if (view.getLayoutParams() instanceof UniLayoutParams)
            {
                UniLayoutParams uniLayoutParams = (UniLayoutParams)view.getLayoutParams();
                if (uniLayoutParams.weight > 0)
                {
                    // Adjust size limitations based on layout property restrictions
                    int wantWidth = (int)(remainingWidth * uniLayoutParams.weight / totalWeight);
                    int viewWidthSpec = widthSpec == MeasureSpec.UNSPECIFIED ? MeasureSpec.UNSPECIFIED : MeasureSpec.AT_MOST;
                    int viewHeightSpec = heightSpec == MeasureSpec.UNSPECIFIED ? MeasureSpec.UNSPECIFIED : MeasureSpec.AT_MOST;
                    int viewWidthSize = remainingWidth;
                    int viewHeightSize = paddedHeightSize;
                    viewWidthSize = Math.max(0, viewWidthSize - uniLayoutParams.leftMargin - uniLayoutParams.rightMargin);
                    viewHeightSize = Math.max(0, viewHeightSize - uniLayoutParams.topMargin - uniLayoutParams.bottomMargin);
                    viewWidthSize = Math.min(viewWidthSize, Math.max(uniLayoutParams.minWidth, Math.min(wantWidth, uniLayoutParams.maxWidth)));
                    viewWidthSpec = MeasureSpec.EXACTLY;
                    if (heightSpec == MeasureSpec.EXACTLY && uniLayoutParams.height == ViewGroup.LayoutParams.MATCH_PARENT)
                    {
                        viewHeightSize = Math.min(viewHeightSize, Math.max(uniLayoutParams.minHeight, uniLayoutParams.maxHeight));
                        viewHeightSpec = MeasureSpec.EXACTLY;
                    }
                    else if (uniLayoutParams.height >= 0)
                    {
                        viewHeightSize = Math.min(viewHeightSize, Math.max(uniLayoutParams.minHeight, Math.min(uniLayoutParams.height, uniLayoutParams.maxHeight)));
                        viewHeightSpec = MeasureSpec.EXACTLY;
                    }
                    else
                    {
                        viewHeightSize = Math.min(viewHeightSize, Math.max(uniLayoutParams.minHeight, uniLayoutParams.maxHeight));
                    }

                    // Obtain final size and make final adjustments per view
                    view.measure(MeasureSpec.makeMeasureSpec(viewWidthSize, viewWidthSpec), MeasureSpec.makeMeasureSpec(viewHeightSize, viewHeightSpec));
                    int resultWidth = view.getMeasuredWidth();
                    int resultHeight = view.getMeasuredHeight();
                    if (!adjustLayout)
                    {
                        resultWidth = 0;
                    }
                    resultWidth = Math.min(viewWidthSize, Math.max(uniLayoutParams.minWidth, resultWidth));
                    resultHeight = Math.min(viewHeightSize, Math.max(uniLayoutParams.minHeight, resultHeight));
                    remainingWidth -= uniLayoutParams.leftMargin + uniLayoutParams.rightMargin;
                    measuredChildSizes.get(i).set(resultWidth, resultHeight);
                    remainingWidth -= resultWidth;
                    totalWeight -= uniLayoutParams.weight;
                }
            }
        }

        // Start doing layout
        int x = getPaddingLeft();
        for (int i = 0; i < childCount; i++)
        {
            // Skip hidden views if they are not part of the layout
            View view = getChildAt(i);
            if (view.getVisibility() == GONE)
            {
                continue;
            }

            // Continue with the others
            Point size = measuredChildSizes.get(i);
            int y = getPaddingTop();
            int nextX = x;
            if (view.getLayoutParams() instanceof UniLayoutParams)
            {
                UniLayoutParams uniLayoutParams = (UniLayoutParams)view.getLayoutParams();
                x += uniLayoutParams.leftMargin;
                y += uniLayoutParams.topMargin;
                if (adjustLayout)
                {
                    y += (paddedHeightSize - uniLayoutParams.topMargin - uniLayoutParams.bottomMargin - size.y) * uniLayoutParams.verticalGravity;
                }
                measuredSize.y = Math.max(measuredSize.y, y + size.y + uniLayoutParams.bottomMargin);
                nextX = x + size.x + uniLayoutParams.rightMargin;
            }
            else
            {
                measuredSize.y = Math.max(measuredSize.y, y + size.y);
                nextX = x + size.x;
            }
            if (adjustLayout)
            {
                view.layout(x, y, x + size.x, y + size.y);
            }
            measuredSize.x = Math.max(measuredSize.x, nextX);
            x = nextX;
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
        if (getOrientation() == VERTICAL)
        {
            performVerticalLayout(measuredSize, MeasureSpec.getSize(widthMeasureSpec), MeasureSpec.getSize(heightMeasureSpec), MeasureSpec.getMode(widthMeasureSpec), MeasureSpec.getMode(heightMeasureSpec), false);
            setMeasuredDimension(measuredSize.x, measuredSize.y);
        }
        else
        {
            performHorizontalLayout(measuredSize, MeasureSpec.getSize(widthMeasureSpec), MeasureSpec.getSize(heightMeasureSpec), MeasureSpec.getMode(widthMeasureSpec), MeasureSpec.getMode(heightMeasureSpec), false);
            setMeasuredDimension(measuredSize.x, measuredSize.y);
        }
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom)
    {
        if (getOrientation() == VERTICAL)
        {
            performVerticalLayout(measuredSize, right - left, bottom - top, MeasureSpec.EXACTLY, MeasureSpec.EXACTLY, true);
        }
        else
        {
            performHorizontalLayout(measuredSize, right - left, bottom - top, MeasureSpec.EXACTLY, MeasureSpec.EXACTLY, true);
        }
    }


    // ---
    // Helper
    // ---

    void prepareChildSizes(int count)
    {
        while (measuredChildSizes.size() < count)
        {
            measuredChildSizes.add(new Point());
        }
    }
}
