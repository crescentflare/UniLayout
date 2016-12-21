package com.crescentflare.unilayout.views;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;

import com.crescentflare.unilayout.helpers.UniLayoutParams;

/**
 * UniLayout view: a simple view
 * Extends View to use UniLayoutParams and provide some minor layout improvements (like padding)
 */
public class UniView extends View
{
    // ---
    // Initialization
    // ---

    public UniView(Context context)
    {
        this(context, (AttributeSet) null);
    }

    public UniView(Context context, AttributeSet attrs)
    {
        super(context, attrs);
        init(attrs);
    }

    public UniView(Context context, AttributeSet attrs, int defStyleAttr)
    {
        this(context, attrs);
    }

    public UniView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes)
    {
        this(context, attrs);
    }

    private void init(AttributeSet attrs)
    {
    }


    // ---
    // Custom layout
    // ---

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec)
    {
        int width = getPaddingLeft() + getPaddingRight();
        int height = getPaddingTop() + getPaddingBottom();
        int widthSpec = MeasureSpec.getMode(widthMeasureSpec);
        int heightSpec = MeasureSpec.getMode(heightMeasureSpec);
        if (widthSpec == MeasureSpec.EXACTLY)
        {
            width = MeasureSpec.getSize(widthMeasureSpec);
        }
        else if (widthSpec == MeasureSpec.AT_MOST)
        {
            width = Math.min(width, MeasureSpec.getSize(widthMeasureSpec));
        }
        if (heightSpec == MeasureSpec.EXACTLY)
        {
            height = MeasureSpec.getSize(heightMeasureSpec);
        }
        else if (heightSpec == MeasureSpec.AT_MOST)
        {
            height = Math.min(height, MeasureSpec.getSize(heightMeasureSpec));
        }
        setMeasuredDimension(width, height);
    }


    // ---
    // Utility
    // ---

    public static void uniMeasure(View view, int viewWidthSize, int viewHeightSize, int parentWidthSpec, int parentHeightSpec, int viewWidthSpec, int viewHeightSpec)
    {
        // Derive view spec from parent
        ViewGroup.LayoutParams viewLayoutParams = view.getLayoutParams();
        if (viewWidthSpec == MeasureSpec.UNSPECIFIED)
        {
            viewWidthSpec = parentWidthSpec == MeasureSpec.UNSPECIFIED ? MeasureSpec.UNSPECIFIED : MeasureSpec.AT_MOST;
        }
        if (viewHeightSpec == MeasureSpec.UNSPECIFIED)
        {
            viewHeightSpec = parentHeightSpec == MeasureSpec.UNSPECIFIED ? MeasureSpec.UNSPECIFIED : MeasureSpec.AT_MOST;
        }
        if (parentWidthSpec == MeasureSpec.EXACTLY && viewLayoutParams.width == ViewGroup.LayoutParams.MATCH_PARENT)
        {
            viewWidthSpec = MeasureSpec.EXACTLY;
        }
        if (parentHeightSpec == MeasureSpec.EXACTLY && viewLayoutParams.height == ViewGroup.LayoutParams.MATCH_PARENT)
        {
            viewHeightSpec = MeasureSpec.EXACTLY;
        }

        // Determine sizing limits
        int viewMinWidth = 0;
        int viewMaxWidth = 0xFFFFFF;
        int viewMinHeight = 0;
        int viewMaxHeight = 0xFFFFFF;
        if (viewLayoutParams instanceof UniLayoutParams)
        {
            viewMinWidth = Math.max(0, ((UniLayoutParams)viewLayoutParams).minWidth);
            viewMaxWidth = ((UniLayoutParams)viewLayoutParams).maxWidth;
            viewMinHeight = Math.max(0, ((UniLayoutParams)viewLayoutParams).minHeight);
            viewMaxHeight = ((UniLayoutParams)viewLayoutParams).maxHeight;
        }

        // Adjust size to measure on based on view limits or forced values
        if (viewWidthSpec == MeasureSpec.EXACTLY)
        {
            viewWidthSize = Math.min(viewWidthSize, Math.max(viewMinWidth, viewMaxWidth));
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
        if (viewHeightSpec == MeasureSpec.EXACTLY)
        {
            viewHeightSize = Math.min(viewHeightSize, Math.max(viewMinHeight, viewMaxHeight));
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

        // Perform first measure and apply forced exact measure again if size restrictions are in place
        view.measure(MeasureSpec.makeMeasureSpec(viewWidthSize, viewWidthSpec), MeasureSpec.makeMeasureSpec(viewHeightSize, viewHeightSpec));
        int resultWidth = view.getMeasuredWidth();
        int resultHeight = view.getMeasuredHeight();
        resultWidth = Math.min(viewWidthSize, Math.max(viewMinWidth, resultWidth));
        resultHeight = Math.min(viewHeightSize, Math.max(viewMinHeight, resultHeight));
        if (resultWidth != view.getMeasuredWidth() || resultHeight != view.getMeasuredHeight())
        {
            view.measure(MeasureSpec.makeMeasureSpec(resultWidth, MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(resultHeight, MeasureSpec.EXACTLY));
        }
    }
}
